//
//  InitCommand.swift
//  
//
//  Created by Marek Fořt on 8/5/19.
//

import Foundation
import PathKit
import TuistGenerator
import TuistCore
import SPMUtility
import Basic
import class Workspace.InitPackage

enum InitCommandError: FatalError, Equatable {
    case ungettableProjectName(AbsolutePath)
    case nonEmptyDirectory(AbsolutePath)

    var type: ErrorType {
        return .abort
    }

    var description: String {
        switch self {
        case let .ungettableProjectName(path):
            return "Couldn't infer the project name from path \(path.pathString)."
        case let .nonEmptyDirectory(path):
            return "Can't initialize a project in the non-empty directory at path \(path.pathString)."
        }
    }

    static func == (lhs: InitCommandError, rhs: InitCommandError) -> Bool {
        switch (lhs, rhs) {
        case let (.ungettableProjectName(lhsPath), .ungettableProjectName(rhsPath)):
            return lhsPath == rhsPath
        case let (.nonEmptyDirectory(lhsPath), .nonEmptyDirectory(rhsPath)):
            return lhsPath == rhsPath
        default:
            return false
        }
    }
}

/// Narrowing down InitPackage.PackageType to types we are supporting
enum PackageType: String, CaseIterable {
    case library, executable
}

/// This command initializes Swift package with example in current empty directory
final class InitCommand: NSObject, Command {
    static var command: String = "init"
    static var overview: String = "Initializes Swift package with example in current directory"

    let pathArgument: OptionArgument<String>

    private let fileHandler: FileHandling
    private let inputReader: InputReading
    private let printer: Printing
    private let exampleGenerator: ExampleGenerating
    private let gitController: GitControlling

    required convenience init(parser: ArgumentParser) {
        let fileHandler = FileHandler()
        self.init(parser: parser, fileHandler: fileHandler, inputReader: InputReader(), printer: Printer(), exampleGenerator: ExampleGenerator(fileHandler: fileHandler), gitController: GitController())
    }

    init(parser: ArgumentParser, fileHandler: FileHandling, inputReader: InputReading, printer: Printing, exampleGenerator: ExampleGenerating, gitController: GitControlling) {
        let subParser = parser.add(subparser: InitCommand.command, overview: InitCommand.overview)

        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to the folder where the project will be generated (Default: Current directory).",
                                     completion: .filename)

        self.fileHandler = fileHandler
        self.inputReader = inputReader
        self.printer = printer
        self.exampleGenerator = exampleGenerator
        self.gitController = gitController
    }

    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments)
        let name = try self.name(path: path)

        let packageType = try initPackage(path: path, name: name)

        switch packageType {
        case .library:
            printer.print("Creating library 📚")
            try exampleGenerator.generateProject(path: path, name: name)
        case .executable:
            printer.print("Creating executable 🏃🏾‍♂️")
        }
        
        try gitController.initGit(path: path)
        
        try generateLicense(path: path)
        
        try generateGitignore(path: path)
        
        try generateTravis(path: path, packageType: packageType, name: name)

        printer.print(success: "Package generated ✅")
    }

    // MARK: - Helpers

    /// Initialize SPM's package
    /// - Returns: PackageType if reading input was successful
    private func initPackage(path: AbsolutePath, name: String) throws -> PackageType {
        let supportedPackageType: PackageType = try inputReader.readEnumInput(question: "Choose package type:")
        let packageType: InitPackage.PackageType
        switch supportedPackageType {
        case .library:
            packageType = .library
        case .executable:
            packageType = .executable
        }

        let initPackage = try InitPackage(name: name, destinationPath: path, packageType: packageType)
        try initPackage.writePackageStructure()

        return supportedPackageType
    }

    /// Obtain package name
    private func name(path: AbsolutePath) throws -> String {
        if let name = path.components.last {
            return name
        } else {
            throw InitCommandError.ungettableProjectName(AbsolutePath.current)
        }
    }

    /// Obtain package path
    private func path(arguments: ArgumentParser.Result) throws -> AbsolutePath {
        if let path = arguments.get(pathArgument) {
            return AbsolutePath(path, relativeTo: fileHandler.currentPath)
        } else {
            return fileHandler.currentPath
        }
    }
    
    /// Generates travis configuration file
    /// - Parameters:
    ///     - path: Path where to generate travis config file
    ///     - packageType: Package type to derive build script command
    ///     - name: Name of package
    private func generateTravis(path: AbsolutePath, packageType: PackageType, name: String) throws {
        let exampleProjectName: String = name + ExampleGenerator.exampleAppendix
        let script: String
        switch packageType {
        case .executable:
            script = "- set -o pipefail && swift test --generate-linuxmain -Xswiftc -target -Xswiftc x86_64-apple-macosx10.12"
        case .library:
            script = "- xcodebuild -project Example/\(exampleProjectName).xcodeproj -scheme \(exampleProjectName) -sdk iphonesimulator -destination 'OS=13.0,name=iPhone Xʀ,platform=iOS Simulator' -configuration Debug ONLY_ACTIVE_ARCH=NO | xcpretty -c"
        }
        let content = """
        osx_image: xcode11
        language: objective-c
        cache:
          directories:
          - Carthage
        env:
          global:
          - FRAMEWORK_NAME=\(name)
        before_install:
        - brew update
        - brew outdated carthage || brew upgrade carthage
        before_deploy:
        - carthage build --no-skip-current --platform iOS --cache-builds
        - carthage archive $FRAMEWORK_NAME
        after_deploy:
        - pod trunk push --skip-import-validation --skip-tests --allow-warnings
        script:
        \(script)
        """
        let travisPath = path.appending(component: ".travis.yml")
        try content.write(to: travisPath.url, atomically: true, encoding: .utf8)
    }
    
    private func generateGitignore(path: AbsolutePath) throws {
        let content = """
        *.xcodeproj/**/xcuserdata/
        *.xcscmblueprint
        /Carthage
        /.build
        .DS_Store
        DerivedData
        .swiftpm/
        
        """
        let gitignorePath = path.appending(component: ".gitignore")
        try content.write(to: gitignorePath.url, atomically: true, encoding: .utf8)
    }
    
    private func generateLicense(path: AbsolutePath) throws {
        let gitName = try gitController.currentName()
        let gitEmail = try gitController.currentEmail()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let content = """
        Copyright \(currentYear)-present, \(gitName); \(gitEmail)

        Permission is hereby granted, free of charge, to any person obtaining a
        copy of this software and associated documentation files (the
        "Software"), to deal in the Software without restriction, including
        without limitation the rights to use, copy, modify, merge, publish,
        distribute, sublicense, and/or sell copies of the Software, and to
        permit persons to whom the Software is furnished to do so, subject to
        the following conditions:

        The above copyright notice and this permission notice shall be included
        in all copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
        OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
        MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
        IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
        CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
        TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
        SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
        """
        
        let licensePath = path.appending(component: "LICENSE")
        try content.write(to: licensePath.url, atomically: true, encoding: .utf8)
    }
}
