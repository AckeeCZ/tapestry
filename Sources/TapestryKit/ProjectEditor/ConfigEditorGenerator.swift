import Foundation
import TuistGenerator
import TSCBasic
import TuistCore
import TapestryCore

public protocol ConfigEditorGenerating {
    /// Generates configEditor project at given path
    func generateProject(path: AbsolutePath, rootPath: AbsolutePath, projectDescriptionPath: AbsolutePath) throws -> AbsolutePath
}

public final class ConfigEditorGenerator: ConfigEditorGenerating {
    private let descriptorGenerator: DescriptorGenerating
    private let writer: XcodeProjWriting
    
    public init(
        descriptorGenerator: DescriptorGenerating = DescriptorGenerator(),
        writer: XcodeProjWriting = XcodeProjWriter()
    ) {
        self.descriptorGenerator = descriptorGenerator
        self.writer = writer
    }
    
    // MARK: - Public methods
    public func generateProject(path: AbsolutePath, rootPath: AbsolutePath, projectDescriptionPath: AbsolutePath) throws -> AbsolutePath {
        let (project, graph) = try projectWithGraph(
            at: path,
            rootPath: rootPath,
            projectDescriptionPath: projectDescriptionPath
        )
        
        let descriptor = try descriptorGenerator.generateProject(
            project: project,
            graph: graph
        )
        try writer.write(project: descriptor)
        return descriptor.xcodeprojPath
    }
    
    // MARK: - Helpers
    
    private func projectWithGraph(
        at path: AbsolutePath,
        rootPath: AbsolutePath,
        projectDescriptionPath: AbsolutePath
    ) throws -> (Project, Graph) {
        let sources = try Target.sources(
            targetName: "Tapestry",
            sources: [
                SourceFileGlob(
                    glob: rootPath.pathString + "/TapestryConfig.swift",
                    excluding: [],
                    compilerFlags: nil
                )
            ]
        )
        
        let targetSettings = Settings(
            base: settings(projectDescriptionPath: projectDescriptionPath),
            configurations: Settings.default.configurations,
            defaultSettings: .recommended
        )
        
        let target = Target(
            name: "Tapestry",
            platform: .macOS,
            product: .staticFramework,
            productName: nil,
            bundleId: "ackee.tapestry",
            settings: targetSettings,
            sources: sources,
            filesGroup: .group(name: "TapestryConfig"),
            dependencies: []
        )
        
        let project = Project(
            path: path,
            sourceRootPath: path,
            xcodeProjPath: path.appending(component: "Tapestry.xcodeproj"),
            name: "Tapestry",
            organizationName: "ackee",
            developmentRegion: nil,
            settings: .default,
            filesGroup: .group(name: "TapestryConfig"),
            targets: [
                target,
            ],
            packages: [],
            schemes: [],
            additionalFiles: []
        )
        
        let graph = Graph(
            name: "Tapestry",
            entryPath: path,
            entryNodes: [GraphNode(path: path, name: "Tapestry")],
            workspace: Workspace(
                path: path,
                name: "Tapestry",
                projects: [path]
            ),
            projects: [project],
            cocoapods: [],
            packages: [],
            precompiled: [],
            targets: [
                path: [
                    TargetNode(
                        project: project,
                        target: target,
                        dependencies: []
                    )
                ]
            ]
        )
        
        return (project, graph)
    }
    
    /// It returns the build settings that should be used in the manifests target.
    /// - Parameter projectDescriptionPath: Path to the ProjectDescription framework.
    private func settings(projectDescriptionPath: AbsolutePath) -> [String: SettingValue] {
        let frameworkParentDirectory = projectDescriptionPath.parentDirectory
        var buildSettings = [String: SettingValue]()
        buildSettings["FRAMEWORK_SEARCH_PATHS"] = .string(frameworkParentDirectory.pathString)
        buildSettings["LIBRARY_SEARCH_PATHS"] = .string(frameworkParentDirectory.pathString)
        buildSettings["SWIFT_INCLUDE_PATHS"] = .string(frameworkParentDirectory.pathString)
        return buildSettings
    }
}
