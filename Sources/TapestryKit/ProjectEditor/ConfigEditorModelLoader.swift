//import Foundation
//import TSCBasic
//import TuistGenerator
//
///// Loads project for example
//public final class ConfigEditorModelLoader: GeneratorModelLoading {
//    private let rootPath: AbsolutePath
//    private let projectDescriptionPath: AbsolutePath
//    
//    /// - Parameters:
//    public init(rootPath: AbsolutePath,
//                projectDescriptionPath: AbsolutePath) {
//        self.rootPath = rootPath
//        self.projectDescriptionPath = projectDescriptionPath
//    }
//
//    /// Loads project for example
//    public func loadProject(at path: AbsolutePath) throws -> Project {
//        let sources = try TuistGenerator.Target.sources(projectPath: path, sources: [(glob: rootPath.pathString + "/TapestryConfig.swift", compilerFlags: nil)])
//        
//        let targetSettings = Settings(base: settings(projectDescriptionPath: projectDescriptionPath),
//                                      configurations: Settings.default.configurations,
//                                      defaultSettings: .recommended)
//        
//        return Project(path: path,
//                       name: "Tapestry",
//                       settings: .default,
//                       filesGroup: .group(name: "TapestryConfig"),
//                       targets: [
//                        Target(name: "Tapestry",
//                               platform: .macOS,
//                               product: .staticFramework,
//                               productName: nil,
//                               bundleId: "ackee.tapestry",
//                               settings: targetSettings,
//                               sources: sources,
//                               filesGroup: .group(name: "TapestryConfig"),
//                               dependencies: [])],
//                       packages: [],
//                       schemes: [])
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
//    
//    /// It returns the build settings that should be used in the manifests target.
//    /// - Parameter projectDescriptionPath: Path to the ProjectDescription framework.
//    fileprivate func settings(projectDescriptionPath: AbsolutePath) -> [String: SettingValue] {
//        let frameworkParentDirectory = projectDescriptionPath.parentDirectory
//        var buildSettings = [String: SettingValue]()
//        buildSettings["FRAMEWORK_SEARCH_PATHS"] = .string(frameworkParentDirectory.pathString)
//        buildSettings["LIBRARY_SEARCH_PATHS"] = .string(frameworkParentDirectory.pathString)
//        buildSettings["SWIFT_INCLUDE_PATHS"] = .string(frameworkParentDirectory.pathString)
////        buildSettings["SWIFT_VERSION"] = .string(Constants.swiftVersion)
//        return buildSettings
//    }
//}
