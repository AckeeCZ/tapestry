import Foundation
import TuistGenerator
import Basic
import TuistCore

protocol FrameworkGenerating {
    /// Generates Framework project at given path
    func generateProject(path: AbsolutePath, name: String) throws
}

final class FrameworkGenerator: FrameworkGenerating {
    
    static let FrameworkAppendix: String = "Framework"

    private let fileHandler: FileHandling

    init(fileHandler: FileHandling) {
        self.fileHandler = fileHandler
    }

    // MARK: - Public methods

    func generateProject(path: AbsolutePath, name: String) throws {
        let generator = Generator(modelLoader: FrameworkModelLoader(name: name))
        _ = try generator.generateProject(at: path)
    }
}
