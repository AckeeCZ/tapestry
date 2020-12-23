import TapestryCore
import TSCBasic
import TSCUtility

public final class MockGitController: GitControlling {
    public var initGitStub: ((AbsolutePath) throws -> ())?
    public var nameStub: (() throws -> String)?
    public var emailStub: (() throws -> String)?
    public var tagVersionStub: ((Version, AbsolutePath?) throws -> ())?
    public var commitStub: ((String, AbsolutePath?) throws -> ())?
    public var tagExistsStub: ((Version, AbsolutePath?) throws -> Bool)?
    public var addStub: (([AbsolutePath], AbsolutePath?) throws -> ())?
    public var pushStub: ((AbsolutePath?) throws -> ())?
    public var pushTagStub: ((String, AbsolutePath?) throws -> ())?
    public var allTagsStub: ((AbsolutePath?) throws -> [Version])?
    
    public var deleteTagStub: ((Version, AbsolutePath?) throws -> Void)?
    public func deleteTagVersion(_ version: Version, path: AbsolutePath?) throws {
        try deleteTagStub?(version, path)
    }
    
    public func initGit(path: AbsolutePath) throws {
        try initGitStub?(path)
    }
    
    public func currentName() throws -> String {
        try nameStub?() ?? ""
    }
    
    public func currentEmail() throws -> String {
        try emailStub?() ?? ""
    }
    
    public func tagVersion(_ version: Version, path: AbsolutePath?) throws {
        try tagVersionStub?(version, path)
    }
    
    public func commit(_ message: String, path: AbsolutePath?) throws {
        try commitStub?(message, path)
    }
    
    public func tagExists(_ version: Version, path: AbsolutePath?) throws -> Bool {
        try tagExistsStub?(version, path) ?? false
    }
    
    public func add(files: [AbsolutePath], path: AbsolutePath?) throws {
        try addStub?(files, path)
    }
    
    public func push(path: AbsolutePath?) throws {
        try pushStub?(path)
    }
    
    public func pushTag(
        _ tag: String,
        path: AbsolutePath?
    ) throws {
        try pushTagStub?(tag, path)
    }
    
    public func allTags(path: AbsolutePath?) throws -> [Version] {
        try allTagsStub?(path) ?? []
    }
}
