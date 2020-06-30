import TuistCore
import TuistGenerator
import XcodeProj
import TSCBasic
import PathKit

final class MockDescriptorGenerator: DescriptorGenerating {
    var generateProjectStub: ((Project, Graph) throws -> ProjectDescriptor)?
    func generateProject(project: Project, graph: Graph) throws -> ProjectDescriptor {
        try generateProjectStub?(project, graph) ?? ProjectDescriptor.test()
    }
    
    var generateProjectStub: ((Project, Graph, ProjectGenerationConfig) throws -> ProjectDescriptor)
    func generateProject(project: Project, graph: Graph, config: ProjectGenerationConfig) throws -> ProjectDescriptor {
        try generateProjectStub?(project, graph, config) ?? ProjectDescriptor.test()
    }
    
    var generateProjectStub: ((Workspace, Graph) throws -> ProjectDescriptor)
    func generateWorkspace(workspace: Workspace, graph: Graph) throws -> WorkspaceDescriptor {
        try generateProjectStub?(workspace, graph) ?? ProjectDescriptor.test()
    }
}
