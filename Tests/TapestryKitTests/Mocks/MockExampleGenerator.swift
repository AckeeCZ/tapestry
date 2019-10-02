import TapestryGen
import Basic

final class MockExampleGenerator: ExampleGenerating {
    var generateProjectStub: ((AbsolutePath, String, String) throws -> ())?
    
    func generateProject(path: AbsolutePath, name: String, bundleId: String) throws {
        try generateProjectStub?(path, name, bundleId)
    }
}
