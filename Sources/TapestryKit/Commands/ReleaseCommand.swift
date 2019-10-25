import Foundation
import protocol TuistCore.FatalError
import protocol TuistCore.Command
import enum TuistCore.ErrorType
import TapestryCore
import TapestryGen
import Basic
import SPMUtility

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
    static var overview: String = "Runs release steps defined in `TapestryConfig.swift` file"

    let versionArgument: PositionalArgument<Version>
    let pathArgument: OptionArgument<String>

    private let configModelLoader: ConfigModelLoading
    private let docsUpdater: DocsUpdating
    private let dependenciesCompatibilityChecker: DependenciesCompatibilityChecking

    required convenience init(parser: ArgumentParser) {
        let graphManifestLoader = GraphManifestLoader()
        let configModelLoader = ConfigModelLoader(manifestLoader: graphManifestLoader)
        self.init(parser: parser,
                  configModelLoader: configModelLoader,
                  docsUpdater: DocsUpdater(),
                  dependenciesCompatibilityChecker: DependenciesCompatibilityChecker())
    }

    init(parser: ArgumentParser,
         configModelLoader: ConfigModelLoading,
         docsUpdater: DocsUpdating,
         dependenciesCompatibilityChecker: DependenciesCompatibilityChecking) {
        let subParser = parser.add(subparser: ReleaseCommand.command, overview: ReleaseCommand.overview)
        versionArgument = subParser.add(positional: "Version", kind: Version.self)
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to the folder where the project will be generated (Default: Current directory).",
                                     completion: .filename)

        self.configModelLoader = configModelLoader
        self.docsUpdater = docsUpdater
        self.dependenciesCompatibilityChecker = dependenciesCompatibilityChecker
    }

    func run(with arguments: ArgumentParser.Result) throws {
        guard let version = arguments.get(versionArgument) else { throw ReleaseError.noVersion }
        
        let path = try self.path(arguments: arguments)
        
        guard try !GitController.shared.tagExists(version, path: path) else { throw ReleaseError.tagExists(version) }
        
        let config = try configModelLoader.loadTapestryConfig(at: path.appending(RelativePath("Tapestries/Sources/TapestryConfig/TapestryConfig.swift")))
        
        let preActions: [ReleaseAction.Action] = config.release.actions
            .filter { $0.isPre }
            .map { updateArguments(for: $0, version: version) }
        try preActions.forEach { try runReleaseAction($0, path: path, version: version) }
        
        try updateGit(with: config, version: version, path: path)
        
        let postActions: [ReleaseAction.Action] = config.release.actions
            .filter { $0.isPost }
            .map { updateArguments(for: $0, version: version) }
        try postActions.forEach { try runReleaseAction($0, path: path, version: version) }
        
        Printer.shared.print(success: "Version updated to \(version.description) 🎉")
    }
    
    // MARK: - Helpers
    
    /// Runs git stage of release
    private func updateGit(with config: TapestryConfig, version: Version, path: AbsolutePath) throws {
        let addFiles = config.release.add.map { path.appending(RelativePath($0)) }
        if !addFiles.isEmpty {
            try GitController.shared.add(files: addFiles, path: path)
            try GitController.shared.commit(config.release.commitMessage.replacingOccurrences(of: Argument.version.rawValue, with: version.description), path: path)
        }
        
        Printer.shared.print("Updating version 🚀")
        
        try GitController.shared.tagVersion(version,
                                     path: path)
        
        if config.release.push {
            Printer.shared.print("Pushing...")
            try GitController.shared.push(path: path)
            try GitController.shared.pushTags(path: path)
        }
    }
    
    private func updateArguments(for releaseAction: ReleaseAction, version: Version) -> ReleaseAction.Action {
        switch releaseAction.action {
        case let .custom(tool: tool, arguments: arguments):
            let actionArguments = arguments.map { $0 == Argument.version.rawValue ? version.description : $0 }
            return .custom(tool: tool,
                           arguments: actionArguments)
        case let .predefined(action):
            return .predefined(action)
        }
    }
    
    private func runReleaseAction(_ action: ReleaseAction.Action, path: AbsolutePath, version: Version) throws {
        switch action {
        case let .custom(tool: tool, arguments: arguments):
            try System.shared.runAndPrint([tool] + arguments)
        case let .predefined(action):
            switch action {
            case .docsUpdate:
                try docsUpdater.updateDocs(path: path, version: version)
            case let .run(tool: tool, arguments: arguments):
                try PackageController.shared.run(tool, arguments: arguments, path: path)
            case let .dependenciesCompatibility(dependenciesManagers):
                try dependenciesCompatibilityChecker.checkCompatibility(with: dependenciesManagers, path: path)
            }
        }
    }
    
    /// Obtain package path
    private func path(arguments: ArgumentParser.Result) throws -> AbsolutePath {
        if let path = arguments.get(pathArgument) {
            return AbsolutePath(path, relativeTo: FileHandler.shared.currentPath)
        } else {
            return FileHandler.shared.currentPath
        }
    }
}
