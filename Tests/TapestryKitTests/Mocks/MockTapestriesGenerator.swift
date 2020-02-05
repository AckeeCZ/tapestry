import TapestryGen
import Basic

final class MocktapestryConfigGenerator: TapestryConfigGenerating {
    var generateTapestryConfigStub: ((AbsolutePath) throws -> ())?
    
    func generateTapestryConfig(at path: AbsolutePath) throws {
        try generateTapestryConfigStub?(path)
    }
}
