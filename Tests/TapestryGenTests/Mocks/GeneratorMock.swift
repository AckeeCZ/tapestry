import TuistCore
import TuistGenerator
import XcodeProj
import TSCBasic
import PathKit

final class MockDescriptorGenerator: DescriptorGenerating {
    var generateProjectStub: ((Project, Graph) throws -> ProjectDescriptor)?
    func generateProject(project: Project, graph: Graph) throws -> ProjectDescriptor {
        try generateProjectStub?(project, graph) ?? ProjectDescriptor(
            path: AbsolutePath("/test"),
            xcodeprojPath: AbsolutePath("/test"),
            xcodeProj: XcodeProj(path: Path("/test")),
            schemeDescriptors: [],
            sideEffectDescriptors: []
        )
    }
    
    func generateProject(project: Project, graph: Graph, config: ProjectGenerationConfig) throws -> ProjectDescriptor {
        fatalError()
    }
    
    func generateWorkspace(workspace: Workspace, graph: Graph) throws -> WorkspaceDescriptor {
        fatalError()
    }
}
