import Foundation
import TuistGenerator
import Basic
import class TuistGenerator.Generator
import TapestryCore

public protocol ConfigEditorGenerating {
    /// Generates configEditor project at given path
    func generateProject(path: AbsolutePath, rootPath: AbsolutePath, projectDescriptionPath: AbsolutePath) throws -> AbsolutePath
}

public final class ConfigEditorGenerator: ConfigEditorGenerating {
    private let generatorInit: GeneratorInit
    
    public typealias GeneratorInit = ((_ rootPath: AbsolutePath, _ projectDescriptionPath: AbsolutePath) -> Generating)

    /// - Parameters:
    public init(generatorInit: @escaping GeneratorInit = { Generator(modelLoader: ConfigEditorModelLoader(rootPath: $0, projectDescriptionPath: $1)) }) {
        self.generatorInit = generatorInit
    }

    // MARK: - Public methods
    public func generateProject(path: AbsolutePath, rootPath: AbsolutePath, projectDescriptionPath: AbsolutePath) throws -> AbsolutePath {
        let generator = generatorInit(rootPath, projectDescriptionPath)
        return try generator.generateProject(at: path)
    }
}
