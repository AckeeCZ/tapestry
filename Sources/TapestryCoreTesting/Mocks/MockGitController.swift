import TapestryCore
import Basic
import SPMUtility

public final class MockGitController: GitControlling {
    public var initGitStub: ((AbsolutePath) throws -> ())?
    public var nameStub: (() throws -> String)?
    public var emailStub: (() throws -> String)?
    public var tagVersionStub: ((Version) throws -> ())?
    
    public func initGit(path: AbsolutePath) throws {
        try initGitStub?(path)
    }
    
    public func currentName() throws -> String {
        return try nameStub?() ?? ""
    }
    
    public func currentEmail() throws -> String {
        return try emailStub?() ?? ""
    }
    
    public func tagVersion(_ version: Version) throws {
        try tagVersionStub?(version)
    }
}
