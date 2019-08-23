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
import acho
import SPMUtility
import Basic
import class Workspace.InitPackage

class TapestryModelLoader: GeneratorModelLoading {
    func loadProject(at path: AbsolutePath) throws -> Project {
        let sources = try TuistGenerator.Target.sources(projectPath: path, sources: [(glob: "Sources/**", compilerFlags: nil)])

        return Project(path: path, name: "Name", settings: .default, filesGroup: .group(name: "Project"), targets: [Target(name: "Target_name", platform: .iOS, product: .app, productName: nil, bundleId: "bundle-id", sources: sources, filesGroup: .group(name: "Project"))], schemes: [])
    }

    /// We do not use workspace
    func loadWorkspace(at path: AbsolutePath) throws -> Workspace {
        return Workspace(name: "", projects: [])
    }

    func loadTuistConfig(at path: AbsolutePath) throws -> TuistConfig {
        return TuistConfig(compatibleXcodeVersions: .all, generationOptions: [.generateManifest])
    }
    /**
     private func pathTo(_ relativePath: String) -> AbsolutePath {
         return path.appending(RelativePath(relativePath))
     }
    */
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

        let initPackage = try InitPackage(name: name, destinationPath: path, packageType: packageType())
        try initPackage.writePackageStructure()

        // TODO: Generate example project here with dependency

        // _ = listOptions(["CLI Tool", "Framework"], prompt: "What type of project do you want to create?")
        
        //let generator = Generator(modelLoader: TapestryModelLoader())
        //let path = try generator.generateProject(at: AbsolutePath("/Users/marekfort/Development/ackee/TapestryTests"))
    }

    // MARK: - Helpers

    private func packageType() throws -> InitPackage.PackageType {
        let packageType: SupportedPackageType = try inputReader.readEnumInput(question: "Choose package type")
        switch packageType {
        case .library:
            return .library
        case .executable:
            return .executable
        }
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

    /// Checks if the given directory is empty, essentially that it doesn't contain any file or directory.
    ///
    /// - Parameter path: Directory to be checked.
    /// - Throws: An InitCommandError.nonEmptyDirectory error when the directory is not empty.
    private func verifyDirectoryIsEmpty(path: AbsolutePath) throws {
        if !path.glob("*").isEmpty {
            throw InitCommandError.nonEmptyDirectory(path)
        }
    }

    /**
     List options and prompt the user which one he/she wants to use
     - Parameters:
        - options: List of options to present to user
        - prompt: Description of the presented question/options
    */
    private func listOptions(_ options: [String], prompt: String) -> Int {
        // Prints targets as a list so user can choose with which one they want to bind their files
//        options.enumerated().forEach { index, option in
//            print("\(index + 1). " + option)
//        }
//
//        let index = Input.readInt(
//            prompt: prompt,
//            validation: [.within(1...options.count)],
//            errorResponse: { input, _ in
//                self.stderr <<< "'\(input)' is invalid; must be a number between 1 and \(options.count)"
//            }
//        )

        return 0
    }

}

enum SupportedPackageType: String, CaseIterable {
    case library, executable
}
