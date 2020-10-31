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
    
    var generateWorkspaceStub: ((Graph) throws -> WorkspaceDescriptor)?
    func generateWorkspace(graph: Graph) throws -> WorkspaceDescriptor {
        try generateWorkspaceStub?(graph) ?? WorkspaceDescriptor.test()
    }
}
