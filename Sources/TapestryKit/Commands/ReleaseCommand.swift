import Foundation
import protocol TuistCore.FatalError
import protocol TuistCore.Command
import enum TuistCore.ErrorType
import TapestryCore
import Basic
import SPMUtility
import PackageDescription

enum ReleaseError: FatalError, Equatable {
    case noVersion, ungettableProjectName(AbsolutePath), tagExists(Version)

    var type: ErrorType {
        return .abort
    }

    var description: String {
        switch self {
        case .noVersion:
            return "No version provided."
        case let .ungettableProjectName(path):
            return "Couldn't infer the project name from path \(path.pathString)."
        case let .tagExists(version):
            return "Version tag \(version) already exists."
        }
    }
    
    static func == (lhs: ReleaseError, rhs: ReleaseError) -> Bool {
        switch (lhs, rhs) {
        case let (.ungettableProjectName(lhsPath), .ungettableProjectName(rhsPath)):
            return lhsPath == rhsPath
        case (.noVersion, .noVersion):
            return true
        case let (.tagExists(lhsVersion), .tagExists(rhsVersion)):
            return lhsVersion == rhsVersion
        default:
            return false
        }
    }
}

/// This command initializes Swift package with example in current empty directory
final class ReleaseCommand: NSObject, Command {
    static var command: String = "release"
    static var overview: String = "Tags a new release and updates documentation and Pod accordingly"

    let versionArgument: PositionalArgument<Version>
    let pathArgument: OptionArgument<String>

    private let gitController: GitControlling

    required convenience init(parser: ArgumentParser) {
        self.init(parser: parser,
                  gitController: GitController())
    }

    init(parser: ArgumentParser,
         gitController: GitControlling) {
        let subParser = parser.add(subparser: ReleaseCommand.command, overview: ReleaseCommand.overview)
        versionArgument = subParser.add(positional: "Version", kind: Version.self)
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to the folder where the project will be generated (Default: Current directory).",
                                     completion: .filename)

        self.gitController = gitController
    }

    func run(with arguments: ArgumentParser.Result) throws {
        guard let version = arguments.get(versionArgument) else { throw ReleaseError.noVersion }
        
        Printer.shared.print("Updating version 🚀")
        
        let path = try self.path(arguments: arguments)
        let name = try self.name(path: path)
        
        let graphManifestLoader = GraphManifestLoader()
        let configModelLoader = ConfigModelLoader(manifestLoader: graphManifestLoader)
        let config = try configModelLoader.loadTapestryConfig(at: path.appending(RelativePath("Tapestries/Sources/TapestryConfig/TapestryConfig.swift")))
        
        guard try !gitController.tagExists(version, path: path) else { throw ReleaseError.tagExists(version) }
        
        try gitController.commit("Version \(version.description)", path: path)
        
        try gitController.tagVersion(version,
                                     path: path)
        
        Printer.shared.print(success: "Version updated to \(version.description) 🎉")
    }
    
    // MARK: - Helpers
    
    /// Obtain package path
    private func path(arguments: ArgumentParser.Result) throws -> AbsolutePath {
        if let path = arguments.get(pathArgument) {
            return AbsolutePath(path, relativeTo: FileHandler.shared.currentPath)
        } else {
            return FileHandler.shared.currentPath
        }
    }
    
    /// Obtain package name
    /// - Parameters:
    ///     - path: Name is derived from this path (last component)
    private func name(path: AbsolutePath) throws -> String {
        if let name = path.components.last {
            return name
        } else {
            throw InitCommandError.ungettableProjectName(AbsolutePath.current)
        }
    }
}
