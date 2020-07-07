import Foundation
import TSCBasic
import TSCUtility
import TapestryCore
import TapestryGen
import protocol TuistSupport.FatalError
import enum TuistSupport.ErrorType

enum ReleaseError: FatalError, Equatable {
    case ungettableProjectName(AbsolutePath), tagExists(Version)

    var type: ErrorType {
        return .abort
    }

    var description: String {
        switch self {
        case let .ungettableProjectName(path):
            return "Couldn't infer the project name from path \(path.pathString)."
        case let .tagExists(version):
            return "Version tag \(version) already exists."
        }
    }
}

final class ReleaseService {
    private let configModelLoader: ConfigModelLoading
    private let docsUpdater: DocsUpdating
    private let dependenciesCompatibilityChecker: DependenciesCompatibilityChecking
    private let releaseController: ReleaseControlling
    
    init(
        configModelLoader: ConfigModelLoading = ConfigModelLoader(manifestLoader: GraphManifestLoader()),
        docsUpdater: DocsUpdating = DocsUpdater(),
        dependenciesCompatibilityChecker: DependenciesCompatibilityChecking = DependenciesCompatibilityChecker(),
        releaseController: ReleaseControlling = ReleaseController()
    ) {
        self.configModelLoader = configModelLoader
        self.docsUpdater = docsUpdater
        self.dependenciesCompatibilityChecker = dependenciesCompatibilityChecker
        self.releaseController = releaseController
    }
    
    func run(
        path: String?,
        version: Version
    ) throws {
        let path = self.path(path)
        
        guard try !GitController.shared.tagExists(version, path: path) else { throw ReleaseError.tagExists(version) }
        
        let config = try configModelLoader.loadTapestryConfig(at: path.appending(RelativePath("TapestryConfig.swift")))
        
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
            case let .githubRelease(owner: owner, repository: repository):
                try releaseController.release(
                    version,
                    path: path,
                    owner: owner,
                    repository: repository
                )
            case .docsUpdate:
                try docsUpdater.updateDocs(path: path, version: version)
            case let .dependenciesCompatibility(dependenciesManagers):
                try dependenciesCompatibilityChecker.checkCompatibility(with: dependenciesManagers, path: path)
            }
        }
    }
    
    private func path(_ path: String?) -> AbsolutePath {
        if let path = path {
            return AbsolutePath(path, relativeTo: FileHandler.shared.currentPath)
        } else {
            return FileHandler.shared.currentPath
        }
    }
}
