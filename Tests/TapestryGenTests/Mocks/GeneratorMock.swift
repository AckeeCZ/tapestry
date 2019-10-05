import TuistGenerator
import Basic

final class MockGenerator: Generating {
    var generateProjectStub: ((AbsolutePath) throws -> AbsolutePath)?
    
    func generateProject(at path: AbsolutePath) throws -> AbsolutePath {
        return try generateProjectStub?(path) ?? path
    }
    
    func generateProjectWorkspace(at path: AbsolutePath, workspaceFiles: [AbsolutePath]) throws -> AbsolutePath {
        return path
    }
    
    func generateWorkspace(at path: AbsolutePath, workspaceFiles: [AbsolutePath]) throws -> AbsolutePath {
        return path
    }
}
