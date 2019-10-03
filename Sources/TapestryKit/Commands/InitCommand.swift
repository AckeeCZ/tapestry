import Foundation
import TapestryCore
import TapestryGen
import TuistCore
import SPMUtility
import Basic
import Xcodeproj
import class Workspace.Workspace

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

/// This command initializes Swift package with example in current empty directory
final class InitCommand: NSObject, Command {
    static var command: String = "init"
    static var overview: String = "Initializes Swift package with example in current directory"

    let pathArgument: OptionArgument<String>

    private let fileHandler: FileHandling
    private let printer: TapestryCore.Printing
    private let exampleGenerator: ExampleGenerating
    private let gitController: GitControlling
    private let system: Systeming
    private let packageGenerator: PackageGenerating

    required convenience init(parser: ArgumentParser) {
        self.init(parser: parser,
                  fileHandler: FileHandler(),
                  printer: Printer(),
                  exampleGenerator: ExampleGenerator(),
                  gitController: GitController(),
                  system: System(),
                  packageGenerator: PackageGenerator())
    }

    init(parser: ArgumentParser,
         fileHandler: FileHandling,
         printer: TapestryCore.Printing,
         exampleGenerator: ExampleGenerating,
         gitController: GitControlling,
         system: Systeming,
         packageGenerator: PackageGenerating) {
        let subParser = parser.add(subparser: InitCommand.command, overview: InitCommand.overview)

        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to the folder where the project will be generated (Default: Current directory).",
                                     completion: .filename)

        self.fileHandler = fileHandler
        self.printer = printer
        self.exampleGenerator = exampleGenerator
        self.gitController = gitController
        self.system = system
        self.packageGenerator = packageGenerator
    }

    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments)
        let name = try self.name(path: path)

        try verifyDirectoryIsEmpty(path: path)
        
        let packageType = try packageGenerator.initPackage(path: path, name: name)
        
        try gitController.initGit(path: path)
        
        let authorName = try self.authorName()
        let email = try self.email()
        let username = try self.username(email: email)
        let bundleId = try self.bundleId(username: username, projectName: name)
        
        switch packageType {
        case .library:
            printer.print("Creating library 📚")
            try exampleGenerator.generateProject(path: path,
                                                 name: name,
                                                 bundleId: bundleId)
        case .executable:
            printer.print("Creating executable 🏃🏾‍♂️")
        }
        
        try generateLicense(authorName: authorName,
                            email: email,
                            path: path)
        try generateGitignore(path: path)
        try generateReadme(path: path,
                           username: username,
                           name: name)
        
        try generateTravis(path: path,
                           packageType: packageType,
                           name: name)
        
        try system.run(["swift", "package", "--package-path", path.pathString, "generate-xcodeproj"])

        printer.print(success: "Package generated ✅")
    }

    // MARK: - Helpers
    
    /// Checks if the given directory is empty, essentially that it doesn't contain any file or directory.
    ///
    /// - Parameter path: Directory to be checked.
    /// - Throws: An InitCommandError.nonEmptyDirectory error when the directory is not empty.
    private func verifyDirectoryIsEmpty(path: AbsolutePath) throws {
        if !path.glob("*").isEmpty {
            throw InitCommandError.nonEmptyDirectory(path)
        }
    }

    /// Obtain package name
    private func name(path: AbsolutePath) throws -> String {
        if let name = path.components.last {
            return name
        } else {
            throw InitCommandError.ungettableProjectName(AbsolutePath.current)
        }
    }
    
    private func authorName() throws -> String {
        return prompt("👋 Author name", defaultValue: try gitController.currentName())
    }
    
    private func email() throws -> String {
        let gitEmail = try gitController.currentEmail()
        return prompt("💌 Email", defaultValue: gitEmail)
    }
    
    private func username(email: String) throws -> String {
        let defaultUsername = email.components(separatedBy: "@").first
        return prompt("🍷 Username", defaultValue: defaultUsername)
    }
    
    private func bundleId(username: String, projectName: String) throws -> String {
        return prompt("📝 Bundle ID", defaultValue: username + "." + projectName)
    }
    
    private func prompt(_ text: String, defaultValue: String? = nil) -> String {
        if let defaultValue = defaultValue {
            printer.print(text + " or press enter to use: \(defaultValue) > ", includeNewline: false)
            let readLine = readLineAndUnwrap()
            return readLine.isEmpty ? defaultValue : readLine
        } else {
            printer.print(text, includeNewline: false)
            let readLine = readLineAndUnwrap()
            return readLine.isEmpty ? prompt("Try again: " + text) : readLine
        }
    }
    
    private func readLineAndUnwrap() -> String {
        return readLine() ?? ""
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
    private func generateTravis(path: AbsolutePath,
                                packageType: PackageType,
                                name: String) throws {
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
    
    private func generateLicense(authorName: String,
                                 email: String,
                                 path: AbsolutePath) throws {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let content = """
        Copyright \(currentYear)-present, \(authorName); \(email)

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
    
    private func generateReadme(path: AbsolutePath,
                                username: String,
                                name: String) throws {
        let content = """
        # \(name)
        [![CI Status](http://img.shields.io/travis/\(username)/\(name).svg?style=flat)](https://travis-ci.org/\(username)/\(name)
        [![Version](https://img.shields.io/cocoapods/v/\(name).svg?style=flat)](http://cocoapods.org/pods/ParallaxOverlay)
        <a href="https://swift.org/package-manager">
                <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
        </a>
        [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

        Say something about your library

        ## Installation

        ### SPM

        `\(name)` is available via [Swift Package Manager](https://swift.org/package-manager).

        ### CocoaPods

        \(name) is available through [CocoaPods](http://cocoapods.org). To install
        it, simply add the following line to your Podfile:

        ```ruby
        pod '\(name)'
        ```
        """
        
        let readmePath = path.appending(component: "README.md")
        try content.write(to: readmePath.url, atomically: true, encoding: .utf8)
    }
}
