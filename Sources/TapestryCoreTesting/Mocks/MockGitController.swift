import TapestryCore
import Basic

public final class MockGitController: GitControlling {
    public var nameStub: (() throws -> String)?
    public var emailStub: (() throws -> String)?
    
    public func initGit(path: AbsolutePath) throws {
        
    }
    
    public func currentName() throws -> String {
        return try nameStub?() ?? ""
    }
    
    public func currentEmail() throws -> String {
        return try emailStub?() ?? ""
    }
}
