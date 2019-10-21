import Foundation
import protocol TuistCore.FatalError
import protocol TuistCore.Command
import class TuistCore.System
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
    static var overview: String = "Tags a new release and updates documentation and Pod accordingly"

    let versionArgument: PositionalArgument<Version>
    let pathArgument: OptionArgument<String>

    private let gitController: GitControlling
    private let docsUpdater: DocsUpdating
    private let packageController: PackageControlling
    private let dependenciesCompatibilityChecker: DependenciesComptabilityChecking

    required convenience init(parser: ArgumentParser) {
        self.init(parser: parser,
                  gitController: GitController(),
                  docsUpdater: DocsUpdater(),
                  packageController: PackageController(),
                  dependenciesCompatibilityChecker: DependenciesComptabilityChecker())
    }

    init(parser: ArgumentParser,
         gitController: GitControlling,
         docsUpdater: DocsUpdating,
         packageController: PackageControlling,
         dependenciesCompatibilityChecker: DependenciesComptabilityChecking) {
        let subParser = parser.add(subparser: ReleaseCommand.command, overview: ReleaseCommand.overview)
        versionArgument = subParser.add(positional: "Version", kind: Version.self)
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to the folder where the project will be generated (Default: Current directory).",
                                     completion: .filename)

        self.gitController = gitController
        self.docsUpdater = docsUpdater
        self.packageController = packageController
        self.dependenciesCompatibilityChecker = dependenciesCompatibilityChecker
    }

    func run(with arguments: ArgumentParser.Result) throws {
        guard let version = arguments.get(versionArgument) else { throw ReleaseError.noVersion }
        
        let path = try self.path(arguments: arguments)
        
        guard try !gitController.tagExists(version, path: path) else { throw ReleaseError.tagExists(version) }
        
        let graphManifestLoader = GraphManifestLoader()
        let configModelLoader = ConfigModelLoader(manifestLoader: graphManifestLoader)
        let config = try configModelLoader.loadTapestryConfig(at: path.appending(RelativePath("Tapestries/Sources/TapestryConfig/TapestryConfig.swift")))
        
        let preActions: [ReleaseAction.Action] = config.release.actions
            .filter { $0.isPre }
            .map { updateArguments(for: $0, version: version) }
        try preActions.forEach { try runReleaseAction($0, path: path, version: version) }
        
        let addFiles = config.release.add.map { path.appending(RelativePath($0)) }
        try gitController.add(files: addFiles, path: path)
        if !addFiles.isEmpty {
            try gitController.commit(config.release.commitMessage.replacingOccurrences(of: Argument.version.rawValue, with: version.description), path: path)
        }
        
        Printer.shared.print("Updating version 🚀")
        
        try gitController.tagVersion(version,
                                     path: path)
        
        if config.release.push {
            Printer.shared.print("Pushing...")
            try gitController.push(path: path)
        }
        
        let postActions: [ReleaseAction.Action] = config.release.actions
            .filter { $0.isPost }
            .map { updateArguments(for: $0, version: version) }
        try postActions.forEach { try runReleaseAction($0, path: path, version: version) }
        
        Printer.shared.print(success: "Version updated to \(version.description) 🎉")
    }
    
    // MARK: - Helpers
    
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
                try packageController.run(tool, arguments: arguments, path: path)
            case let .dependenciesCompatibility(dependenciesManagers):
                break
//                try dependenciesCompatibilityChecker.checkCompatibility(with: dependenciesManagers, path: path)
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

protocol DependenciesComptabilityChecking {
    func checkCompatibility(with dependenciesManagers: [ReleaseAction.DependenciesManager], path: AbsolutePath) throws
}

public final class DependenciesComptabilityChecker: DependenciesComptabilityChecking {
    public func checkCompatibility(with dependenciesManagers: [ReleaseAction.DependenciesManager], path: AbsolutePath) throws {
        try dependenciesManagers.forEach {
            switch $0 {
            case .carthage:
                try checkCarthageCompatibility(path: path)
            case .cocoapods:
                try checkCocoapodsCompatibility(path: path)
            case .spm:
                try checkSPMCompatibility(path: path)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func checkCarthageCompatibility(path: AbsolutePath) throws {
        Printer.shared.print("Checking Carthage compatibility...")
        // Print if errored
        try FileHandler.shared.inDirectory(path) {
            try System.shared.run(["carthage", "build", "--no-skip-current"])
        }
    }
    
    private func checkCocoapodsCompatibility(path: AbsolutePath) throws {
        Printer.shared.print("Checking Cococapods compatibility...")
        // Print if errored
        try FileHandler.shared.inDirectory(path) {
            try System.shared.run(["pod", "lib", "lint"])
        }
    }
    
    private func checkSPMCompatibility(path: AbsolutePath) throws {
        Printer.shared.print("Checking SPM compatibility...")
        // Print if errored
        try FileHandler.shared.inDirectory(path) {
            try System.shared.run(["swift", "build"])
        }
    }
}
