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

class TapestryModelLoader: GeneratorModelLoading {

    private let name: String

    init(name: String) {
        self.name = name
    }

    func loadProject(at path: AbsolutePath) throws -> Project {
        let sources = try TuistGenerator.Target.sources(projectPath: path, sources: [(glob: "Sources/**", compilerFlags: nil)])

        return Project(path: path, name: name, settings: .default, filesGroup: .group(name: name), targets: [Target(name: name, platform: .iOS, product: .app, productName: nil, bundleId: "ackee." + String(name), sources: sources, filesGroup: .group(name: name))], schemes: [])
    }

    /// We do not use workspace
    func loadWorkspace(at path: AbsolutePath) throws -> Workspace {
        return Workspace(name: "", projects: [])
    }

    func loadTuistConfig(at path: AbsolutePath) throws -> TuistConfig {
        return TuistConfig(compatibleXcodeVersions: .all, generationOptions: [.generateManifest])
    }
}

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

final class InitCommand: NSObject, Command {

    // MARK: - Command
    static var command: String = "init"
    static var overview: String = "Init tapestry framework template"

    let pathArgument: OptionArgument<String>

    private let fileHandler: FileHandling
    private let inputReader: InputReading

    required convenience init(parser: ArgumentParser) {
        self.init(parser: parser, fileHandler: FileHandler(), inputReader: InputReader())
    }

    init(parser: ArgumentParser, fileHandler: FileHandling, inputReader: InputReading) {
        let subParser = parser.add(subparser: InitCommand.command, overview: InitCommand.overview)

        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to the folder where the project will be generated (Default: Current directory).",
                                     completion: .filename)

        self.fileHandler = fileHandler
        self.inputReader = inputReader
    }

    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments)
        let name = try self.name(path: fileHandler.currentPath)

        let packageType = try initPackage(path: path, name: name)

        switch packageType {
        case .library:
            let examplePath = path.appending(RelativePath("Example"))
            try fileHandler.createFolder(examplePath)
            try generateProject(path: examplePath, name: name)
        case .executable:
            break
        }
    }

    // MARK: - Helpers

    private func generateProject(path: AbsolutePath, name: String) throws {
        let generator = Generator(modelLoader: TapestryModelLoader(name: name))
        _ = try generator.generateProject(at: path)
    }

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

    private func name(path: AbsolutePath) throws -> String {
        if let name = path.components.last {
            return name
        } else {
            throw InitCommandError.ungettableProjectName(AbsolutePath.current)
        }
    }

    private func path(arguments: ArgumentParser.Result) throws -> AbsolutePath {
        if let path = arguments.get(pathArgument) {
            return AbsolutePath(path, relativeTo: fileHandler.currentPath)
        } else {
            return fileHandler.currentPath
        }
    }
}

enum SupportedPackageType: String, CaseIterable {
    case library, executable
}
