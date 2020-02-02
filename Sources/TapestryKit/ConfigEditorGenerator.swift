import Foundation
import TuistGenerator
import Basic
import class TuistGenerator.Generator
import TapestryCore

public protocol ConfigEditorGenerating {
    /// Generates configEditor project at given path
    func generateProject(path: AbsolutePath) throws -> AbsolutePath
}

public final class ConfigEditorGenerator: ConfigEditorGenerating {
    private let generator: Generating

    /// - Parameters:
    public init(generator: Generating = Generator(modelLoader: ConfigEditorModelLoader())) {
        self.generator = generator
    }

    // MARK: - Public methods
    public func generateProject(path: AbsolutePath) throws -> AbsolutePath {
        try generator.generateProject(at: path)
    }
}
