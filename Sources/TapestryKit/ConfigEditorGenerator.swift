import Foundation
import TuistGenerator
import Basic
import class TuistGenerator.Generator
import TapestryCore

public protocol ConfigEditorGenerating {
    /// Generates configEditor project at given path
    func generateProject(path: AbsolutePath) throws
}

public final class ConfigEditorGenerator: ConfigEditorGenerating {
    private let generatorModelLoader: GeneratorModelLoading

    /// - Parameters:
    public init(generatorModelLoader: GeneratorModelLoading = ConfigEditorModelLoader()) {
        self.generatorModelLoader = generatorModelLoader
    }

    // MARK: - Public methods
    public func generateProject(path: AbsolutePath) throws {
        _ = try generatorModelLoader.loadProject(at: path)
    }
}
