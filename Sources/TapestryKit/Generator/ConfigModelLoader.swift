import TapestryGen
import TapestryDescription
import TapestryCore
import TSCBasic
import class TuistSupport.Glob

/// Entity responsible for package configuration
public protocol ConfigModelLoading {
    /// Load a Tapestry model at the specified path
    ///
    /// - Parameter path: The absolute path for the tapestryconfig model to load
    /// - Returns: The tapestryconfig loaded from the specified path
    /// - Throws: Error encountered during the loading process (e.g. Missing tapestryconfig)
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
    /// - Parameter path: The absolute path for the tapestryconfig model to load
    /// - Returns: The tapestryconfig loaded from the specified path
    /// - Throws: Error encountered during the loading process (e.g. Missing tapestryconfig)
    func loadTapestryConfig(at path: AbsolutePath) throws -> TapestryGen.TapestryConfig {
        let manifest = try manifestLoader.loadTapestryConfig(at: path.parentDirectory)
        return try TapestryGen.TapestryConfig.from(manifest: manifest, path: path)
    }
}


extension TapestryGen.TapestryConfig {
    static func from(manifest: TapestryDescription.TapestryConfig,
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
    static func from(manifest: TapestryDescription.Release) -> TapestryGen.Release {
        let actions = manifest.actions.map(TapestryGen.ReleaseAction.from)
        let add: [String] = manifest.add?.globs.map { $0.glob } ?? []
        return TapestryGen.Release(actions: actions,
                                   add: add,
                                   commitMessage: manifest.commitMessage,
                                   push: manifest.push)
    }
}

extension TapestryGen.ReleaseAction {
        static func from(manifest: TapestryDescription.ReleaseAction) -> TapestryGen.ReleaseAction {
            let order = TapestryGen.ReleaseAction.Order.from(manifest: manifest.order)
            let action: Action
            switch manifest.action {
            case let .custom(tool: tool, arguments: arguments):
                action = .custom(tool: tool, arguments: arguments)
            case let .predefined(predefinedAction):
                switch predefinedAction {
                case let .githubRelease(owner: owner, repository: repository, assetPaths: assetPaths):
                    action = .predefined(
                        .githubRelease(
                            owner: owner,
                            repository: repository,
                            assetPaths: assetPaths.map { RelativePath($0) }
                        )
                    )
                case .docsUpdate:
                    action = .predefined(.docsUpdate)
                case let .dependenciesCompatibility(dependenciesManagers):
                    action = .predefined(.dependenciesCompatibility(dependenciesManagers.compactMap {
                        switch $0 {
                        case .cocoapods:
                            return .cocoapods
                        case .carthage:
                            return .carthage
                        case let .spm(platform):
                            switch platform {
                            case .all:
                                return .spm(.all)
                            case .iOS:
                                return .spm(.iOS)
                            }
                        }
                    }))
                }
            }
            return TapestryGen.ReleaseAction(order: order,
                                             action: action)
        }
}

extension TapestryGen.ReleaseAction.Order {
    static func from(manifest: TapestryDescription.Order) -> TapestryGen.ReleaseAction.Order {
        switch manifest {
        case .pre:
            return .pre
        case .post:
            return .post
        }
    }
}
