import TapestryGen
import PackageDescription
import TapestryCore
import Basic
import class TuistCore.Glob

/// Entity responsible for providing generator models
///
/// Assumptions:
///   - TuistGenerator creates a graph of Project dependencies
///   - The projects are associated with unique paths
///   - Each path only contains one Project
///   - Whenever a dependency is encountered referencing another path,
///     this entity is consulted again to load the model at that path
public protocol ConfigModelLoading {
    /// Load a TusitConfig model at the specified path
    ///
    /// - Parameter path: The absolute path for the tuistconfig model to load
    /// - Returns: The tuistconfig loaded from the specified path
    /// - Throws: Error encountered during the loading process (e.g. Missing tuistconfig)
    func loadTapestryConfig(at path: AbsolutePath) throws -> TapestryGen.TapestryConfig
}

class ConfigModelLoader: ConfigModelLoading {    
    private let manifestLoader: GraphManifestLoading
    
    init(manifestLoader: GraphManifestLoading) {
        self.manifestLoader = manifestLoader
    }
    
    // TODO: Possible improvement - traversing children
    
    /// Load a TusitConfig model at the specified path
    ///
    /// - Parameter path: The absolute path for the tuistconfig model to load
    /// - Returns: The tuistconfig loaded from the specified path
    /// - Throws: Error encountered during the loading process (e.g. Missing tuistconfig)
    func loadTapestryConfig(at path: AbsolutePath) throws -> TapestryGen.TapestryConfig {
        let manifest = try manifestLoader.loadTapestryConfig(at: path.parentDirectory)
        return try TapestryGen.TapestryConfig.from(manifest: manifest, path: path)
    }
}


extension TapestryGen.TapestryConfig {
    static func from(manifest: PackageDescription.TapestryConfig,
                     path: AbsolutePath) throws -> TapestryGen.TapestryConfig {
        guard let releaseManifest = manifest.release else {
            // Provide default
            fatalError()
        }
        let release = TapestryGen.Release.from(manifest: releaseManifest)
        return TapestryGen.TapestryConfig(release: release)
    }
}

extension TapestryGen.Release {
    static func from(manifest: PackageDescription.Release) -> TapestryGen.Release {
        let actions = manifest.actions.map(TapestryGen.ReleaseAction.from)
        let add: [Glob] = manifest.add?.globs.map { Glob(pattern: $0.glob) } ?? []
        return TapestryGen.Release(actions: actions,
                                   add: add,
                                   commitMessage: manifest.commitMessage,
                                   push: manifest.push)
    }
}

extension TapestryGen.ReleaseAction {
        static func from(manifest: PackageDescription.ReleaseAction) -> TapestryGen.ReleaseAction {
            let order = TapestryGen.ReleaseAction.Order.from(manifest: manifest.order)
            let action: Action
            if manifest.tool == "tapestry", let predefinedAction = TapestryGen.ReleaseAction.PredefinedAction(rawValue: manifest.arguments.first ?? "") {
                action = .predefined(predefinedAction)
            } else {
                action = .custom(tool: manifest.tool, arguments: manifest.arguments)
            }
            return TapestryGen.ReleaseAction(order: order,
                                             action: action)
        }
}

extension TapestryGen.ReleaseAction.Order {
    static func from(manifest: PackageDescription.ReleaseAction.Order) -> TapestryGen.ReleaseAction.Order {
        switch manifest {
        case .pre:
            return .pre
        case .post:
            return .post
        }
    }
}

public enum FileElement: Equatable {
    case file(path: AbsolutePath)
    case folderReference(path: AbsolutePath)

    var path: AbsolutePath {
        switch self {
        case let .file(path):
            return path
        case let .folderReference(path):
            return path
        }
    }

    var isReference: Bool {
        switch self {
        case .file:
            return false
        case .folderReference:
            return true
        }
    }
}
