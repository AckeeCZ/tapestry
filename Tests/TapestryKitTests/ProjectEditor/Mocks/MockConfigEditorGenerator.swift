import TSCBasic
@testable import TapestryKit

final class MockConfigEditorGenerator: ConfigEditorGenerating {
    var generateProjectStub: ((AbsolutePath, AbsolutePath, AbsolutePath) throws -> (AbsolutePath))?
    
    /// Generates configEditor project at given path
    func generateProject(path: AbsolutePath, rootPath: AbsolutePath, projectDescriptionPath: AbsolutePath) throws -> AbsolutePath {
        try generateProjectStub?(path, rootPath, projectDescriptionPath) ?? AbsolutePath("/")
    }
}
