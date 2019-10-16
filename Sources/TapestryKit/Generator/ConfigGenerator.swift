import Foundation
import TuistGenerator
import Basic
import class TuistGenerator.Generator
import TapestryCore

public protocol ConfigGenerating {
    /// Generates Config project at given path
    func generateProject(path: AbsolutePath, name: String, bundleId: String) throws
}

public typealias GeneratorInit = ((_ name: String, _ bundleId: String) -> Generating)

public final class ConfigGenerator: ConfigGenerating {
    /// String that describes what should appendix for Config, aka for TapestryConfig it is the part after `Tapestry`
    public static let configFilename: String = "Configuration"
    
    private let generatorInit: GeneratorInit

    /// - Parameters:
    ///     - generatorInit: Closure for creating `Generator`
    public init(generatorInit: @escaping GeneratorInit = { name, bundleId in
        Generator(modelLoader: ConfigModelLoader(packageName: name,
                                                 name: name + ConfigGenerator.configFilename,
                                                 bundleId: bundleId))
        }) {
        self.generatorInit = generatorInit
    }

    // MARK: - Public methods

    public func generateProject(path: AbsolutePath, name: String, bundleId: String) throws {
        let generator = generatorInit(name, bundleId)
        _ = try generator.generateProject(at: path)
    }
}
