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
    
    var generateProjectConfigStub: ((Project, Graph, ProjectGenerationConfig) throws -> ProjectDescriptor)?
    func generateProject(project: Project, graph: Graph, config: ProjectGenerationConfig) throws -> ProjectDescriptor {
        try generateProjectConfigStub?(project, graph, config) ?? ProjectDescriptor.test()
    }
    
    var generateWorkspaceStub: ((Workspace, Graph) throws -> WorkspaceDescriptor)?
    func generateWorkspace(workspace: Workspace, graph: Graph) throws -> WorkspaceDescriptor {
        try generateWorkspaceStub?(workspace, graph) ?? WorkspaceDescriptor.test()
    }
}
