import Foundation
import Basic
import TuistGenerator

/// Loads project for example
public final class ConfigEditorModelLoader: GeneratorModelLoading {
    private let rootPath: AbsolutePath
    
    /// - Parameters:
    public init(rootPath: AbsolutePath) {
        self.rootPath = rootPath
    }

    /// Loads project for example
    public func loadProject(at path: AbsolutePath) throws -> Project {
        let sources = try TuistGenerator.Target.sources(projectPath: path, sources: [(glob: rootPath.pathString + "/TapestryConfig.swift", compilerFlags: nil)])
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
