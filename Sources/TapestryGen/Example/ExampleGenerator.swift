import Foundation
import TuistGenerator
import TuistCore
import TSCBasic
import TapestryCore

public protocol ExampleGenerating {
    /// Generates example project at given path
    func generateProject(path: AbsolutePath, name: String, bundleId: String) throws
}

public final class ExampleGenerator: ExampleGenerating {
    /// String that describes what should appendix for example, aka for TapestryExample it is the part after `Tapestry`
    public static let exampleAppendix: String = "Example"
    
    private let descriptorGenerator: DescriptorGenerating
    
    /// - Parameters:
    ///     - generatorInit: Closure for creating `Generator`
    public init(
        descriptorGenerator: DescriptorGenerating = DescriptorGenerator()
    ) {
        self.descriptorGenerator = descriptorGenerator
    }
    
    // MARK: - Public methods
    public func generateProject(path: AbsolutePath, name: String, bundleId: String) throws {
        let examplePath = path.appending(RelativePath(ExampleGenerator.exampleAppendix))
        try FileHandler.shared.createFolder(examplePath)
        
        try createExampleSources(path: examplePath, name: name)
        
        let (project, graph) = try projectWithGraph(
            at: examplePath,
            name: name + ExampleGenerator.exampleAppendix,
            bundleId: bundleId,
            packageName: name
        )
        _ = try descriptorGenerator.generateProject(project: project, graph: graph)
    }
    
    // MARK: - Helpers
    /// Create sources folder with dummy content
    private func createExampleSources(path: AbsolutePath, name: String) throws {
        let sourcesPath = path.appending(RelativePath("Sources"))
        try FileHandler.shared.createFolder(sourcesPath)
        try generateExampleSourceFile(path: sourcesPath, name: name)
        try generateAppDelegate(path: sourcesPath)
    }
    
    /// Create dummy source file
    private func generateExampleSourceFile(path: AbsolutePath, name: String) throws {
        let content = """
        struct \(name) {
        var text = "Hello, World!"
        }
        
        """
        try content.write(to: path.appending(component: "\(name).swift").url, atomically: true, encoding: .utf8)
    }
    
    // TODO: Add test
    private func generateAppDelegate(path: AbsolutePath) throws {
        let content = """
        import UIKit

        @UIApplicationMain
        class AppDelegate: UIResponder, UIApplicationDelegate {

            var window: UIWindow?

            func application(
                _ application: UIApplication,
                didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
            ) -> Bool {
                window = UIWindow(frame: UIScreen.main.bounds)
                let viewController = UIViewController()
                viewController.view.backgroundColor = .white
                window?.rootViewController = viewController
                window?.makeKeyAndVisible()
                return true
            }

        }

        """
        try content.write(to: path.appending(component: "AppDelegate.swift").url, atomically: true, encoding: .utf8)
    }
    
    private func projectWithGraph(
        at path: AbsolutePath,
        name: String,
        bundleId: String,
        packageName: String
    ) throws -> (Project, Graph) {
        let sources = try Target.sources(
            targetName: name,
            sources: [(glob: path.pathString + "/Sources/**", excluding: [], compilerFlags: nil)]
        )
        let target = Target(
            name: name,
            platform: .iOS,
            product: .app,
            productName: nil,
            bundleId: bundleId,
            sources: sources,
            filesGroup: .group(name: name),
            dependencies: [.package(product: packageName)]
        )
        
        let packagePath = path.appending(RelativePath("../../\(packageName)"))
        let package: Package = .local(path: packagePath)
        
        let project = Project(
            path: path,
            sourceRootPath: path,
            xcodeProjPath: path,
            name: name,
            organizationName: "tapestry.io",
            developmentRegion: nil,
            settings: .default,
            filesGroup: .group(name: name),
            targets: [
                target
            ],
            packages: [
                package
            ],
            schemes: [],
            additionalFiles: []
        )
        
        let graph = Graph(
            name: name,
            entryPath: path,
            entryNodes: [GraphNode(path: path, name: name)],
            workspace: Workspace(
                path: path,
                name: name,
                projects: [path]
            ),
            projects: [project],
            cocoapods: [],
            packages: [PackageNode(package: package, path: packagePath)],
            precompiled: [],
            targets: [
                path: [
                    TargetNode(
                        project: project,
                        target: target,
                        dependencies: [GraphNode(path: packagePath, name: packageName)]
                    )
                ]
            ]
        )
        
        return (project, graph)
    }
}
