import Foundation
import TuistGenerator
import Basic
import class TuistGenerator.Generator
import TapestryCore

public protocol ConfigEditorGenerating {
    /// Generates configEditor project at given path
    func generateProject(path: AbsolutePath, rootPath: AbsolutePath) throws -> AbsolutePath
}

public final class ConfigEditorGenerator: ConfigEditorGenerating {
    private let generatorInit: GeneratorInit
    
    public typealias GeneratorInit = ((_ rootPath: AbsolutePath) -> Generating)

    /// - Parameters:
    public init(generatorInit: @escaping GeneratorInit = { rootPath in Generator(modelLoader: ConfigEditorModelLoader(rootPath: rootPath)) }) {
        self.generatorInit = generatorInit
    }

    // MARK: - Public methods
    public func generateProject(path: AbsolutePath, rootPath: AbsolutePath) throws -> AbsolutePath {
        let generator = generatorInit(rootPath)
        return try generator.generateProject(at: path)
    }
}
