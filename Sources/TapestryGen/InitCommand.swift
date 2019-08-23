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
enum SupportedPackageType: String, CaseIterable {
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

    required convenience init(parser: ArgumentParser) {
        let fileHandler = FileHandler()
        self.init(parser: parser, fileHandler: fileHandler, inputReader: InputReader(), printer: Printer(), exampleGenerator: ExampleGenerator(fileHandler: fileHandler))
    }

    init(parser: ArgumentParser, fileHandler: FileHandling, inputReader: InputReading, printer: Printing, exampleGenerator: ExampleGenerating) {
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
    }

    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments)
        let name = try self.name(path: fileHandler.currentPath)

        let packageType = try initPackage(path: path, name: name)

        switch packageType {
        case .library:
            printer.print("Creating library 📚")
            try exampleGenerator.generateProject(path: path, name: name)
        case .executable:
            printer.print("Creating executable 🏃🏾‍♂️")
        }

        printer.print(success: "Package generated ✅")
    }

    // MARK: - Helpers

    /// Initialize SPM's package
    /// - Returns: SupportedPackageType if reading input was successful
    private func initPackage(path: AbsolutePath, name: String) throws -> SupportedPackageType {
        let supportedPackageType: SupportedPackageType = try inputReader.readEnumInput(question: "Choose package type:")
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
}
