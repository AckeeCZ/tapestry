import Foundation
import Basic
import TuistGenerator

/// Loads project for example
public final class ConfigEditorModelLoader: GeneratorModelLoading {

    /// - Parameters:
    ///     - packageName: Name for package to embed in example
    ///     - name: Name of example
    ///     - bundleId: BundleId for example's `.xcodeproj`
    public init() {
    }

    /// Loads project for example
    public func loadProject(at path: AbsolutePath) throws -> Project {
        let sources = try TuistGenerator.Target.sources(projectPath: path, sources: [(glob: path.pathString + "/TapestryConfig.swift", compilerFlags: nil)])
        return Project(path: path,
                       name: "Tapestry",
                       settings: .default,
                       filesGroup: .group(name: "TapestryConfig"),
                       targets: [
                        Target(name: "Tapestry",
                               platform: .macOS,
                               product: .staticFramework,
                               productName: nil,
                               bundleId: "ackee.tapestry",
                               sources: sources,
                               filesGroup: .group(name: "TapestryConfig"),
                               dependencies: [])],
                       packages: [],
                       schemes: [])
    }

    /// We do not use workspace
    public func loadWorkspace(at path: AbsolutePath) throws -> Workspace {
        return Workspace(name: "", projects: [])
    }

    /// We do not use tuist config
    public func loadTuistConfig(at path: AbsolutePath) throws -> TuistConfig {
        return TuistConfig(compatibleXcodeVersions: .all, generationOptions: [.generateManifest])
    }
}
