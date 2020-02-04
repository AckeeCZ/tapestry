import TapestryGen
import Basic

final class MockTapestriesGenerator: TapestryConfigGenerating {
    var generateTapestryConfigStub: ((AbsolutePath) throws -> ())?
    
    func generateTapestryConfig(at path: AbsolutePath) throws {
        try generateTapestryConfigStub?(path)
    }
}
