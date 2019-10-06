import TapestryCore
import Basic
import SPMUtility

public final class MockGitController: GitControlling {
    public var initGitStub: ((AbsolutePath) throws -> ())?
    public var nameStub: (() throws -> String)?
    public var emailStub: (() throws -> String)?
    public var tagVersionStub: ((Version, AbsolutePath?) throws -> ())?
    public var commitStub: ((String, AbsolutePath?) throws -> ())?
    
    public func initGit(path: AbsolutePath) throws {
        try initGitStub?(path)
    }
    
    public func currentName() throws -> String {
        return try nameStub?() ?? ""
    }
    
    public func currentEmail() throws -> String {
        return try emailStub?() ?? ""
    }
    
    public func tagVersion(_ version: Version, path: AbsolutePath?) throws {
        try tagVersionStub?(version, path)
    }
    
    public func commit(_ message: String, path: AbsolutePath?) throws {
        try commitStub?(message, path)
    }
}
