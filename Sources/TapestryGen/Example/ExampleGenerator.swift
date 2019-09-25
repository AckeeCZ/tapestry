import Foundation
import TuistGenerator
import Basic
import TuistCore

protocol ExampleGenerating {
    /// Generates example project at given path
    func generateProject(path: AbsolutePath, name: String) throws
}

final class ExampleGenerator: ExampleGenerating {
    
    static let exampleAppendix: String = "Example"

    private let fileHandler: FileHandling

    init(fileHandler: FileHandling) {
        self.fileHandler = fileHandler
    }

    // MARK: - Public methods

    func generateProject(path: AbsolutePath, name: String) throws {
        let examplePath = path.appending(RelativePath("Example"))
        try fileHandler.createFolder(examplePath)

        try createExampleSources(path: examplePath, name: name)

        let generator = Generator(modelLoader: ExampleModelLoader(packageName: name, name: name + ExampleGenerator.exampleAppendix))
        _ = try generator.generateProject(at: examplePath)
    }

    // MARK: - Helpers

    /// Create sources folder with dummy content
    private func createExampleSources(path: AbsolutePath, name: String) throws {
        let sourcesPath = path.appending(RelativePath("Sources"))
        try fileHandler.createFolder(sourcesPath)
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
