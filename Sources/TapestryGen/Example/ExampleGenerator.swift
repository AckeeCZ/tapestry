import Foundation
import TuistGenerator
import Basic
import class TuistGenerator.Generator
import TapestryCore

public protocol ExampleGenerating {
    /// Generates example project at given path
    func generateProject(path: AbsolutePath, name: String, bundleId: String) throws
}

public typealias GeneratorInit = ((_ name: String, _ bundleId: String) -> Generating)

public final class ExampleGenerator: ExampleGenerating {
    /// String that describes what should appendix for example, aka for TapestryExample it is the part after `Tapestry`
    public static let exampleAppendix: String = "Example"
    
    private let generatorInit: GeneratorInit

    /// - Parameters:
    ///     - generatorInit: Closure for creating `Generator`
    public init(generatorInit: @escaping GeneratorInit = { name, bundleId in
        Generator(modelLoader: ExampleModelLoader(packageName: name,
                                                  name: name + ExampleGenerator.exampleAppendix,
                                                  bundleId: bundleId))
        }) {
        self.generatorInit = generatorInit
    }

    // MARK: - Public methods
    public func generateProject(path: AbsolutePath, name: String, bundleId: String) throws {
        let examplePath = path.appending(RelativePath(ExampleGenerator.exampleAppendix))
        try FileHandler.shared.createFolder(examplePath)

        try createExampleSources(path: examplePath, name: name)

        let generator = generatorInit(name, bundleId)
        _ = try generator.generateProject(at: examplePath)
    }

    // MARK: - Helpers
    /// Create sources folder with dummy content
    private func createExampleSources(path: AbsolutePath, name: String) throws {
        let sourcesPath = path.appending(RelativePath("Sources"))
        try FileHandler.shared.createFolder(sourcesPath)
        try generateExampleSourceFile(path: sourcesPath, name: name)
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
}
