//import Foundation
//import TSCBasic
//import TuistGenerator
//import TuistCore
//
///// Loads project for example
//public final class ExampleModelLoader: GeneratorModelLoader {
//    private let packageName: String
//    private let name: String
//    private let bundleId: String
//
//    /// - Parameters:
//    ///     - packageName: Name for package to embed in example
//    ///     - name: Name of example
//    ///     - bundleId: BundleId for example's `.xcodeproj`
//    public init(packageName: String, name: String, bundleId: String) {
//        self.packageName = packageName
//        self.name = name
//        self.bundleId = bundleId
//    }
//
//    /// Loads project for example
//    public func loadProject(at path: AbsolutePath) throws -> Project {
//        let sources = try TuistCore.Target.sources(projectPath: path, sources: [(glob: path.pathString + "/Sources/**", compilerFlags: nil)])
//        return Project(path: path,
//                       name: name,
//                       settings: .default,
//                       filesGroup: .group(name: name),
//                       targets: [
//                        Target(name:
//                            name,
//                               platform: .iOS,
//                               product: .app,
//                               productName: nil,
//                               bundleId: bundleId,
//                               sources: sources,
//                               filesGroup: .group(name: name),
//                               dependencies: [.package(product: packageName)])],
//                       packages: [.local(path: path.appending(RelativePath("../../\(packageName)")))], schemes: [])
//    }
//
//    /// We do not use workspace
//    public func loadWorkspace(at path: AbsolutePath) throws -> Workspace {
//        return Workspace(name: "", projects: [])
//    }
//
//    /// We do not use tuist config
//    public func loadTuistConfig(at path: AbsolutePath) throws -> TuistConfig {
//        return TuistConfig(compatibleXcodeVersions: .all, generationOptions: [.generateManifest])
//    }
//}
