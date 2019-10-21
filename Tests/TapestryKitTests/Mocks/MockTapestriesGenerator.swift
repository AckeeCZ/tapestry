import TapestryGen
import Basic

final class MockTapestriesGenerator: TapestriesGenerating {
    var generateTapestriesStub: ((AbsolutePath) throws -> ())?
    
    func generateTapestries(at path: AbsolutePath) throws {
        try generateTapestriesStub?(path)
    }
}
