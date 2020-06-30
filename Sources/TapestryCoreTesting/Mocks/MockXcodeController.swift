import TapestryCore
import TSCBasic

public final class MockXcodeController: XcodeControlling {
    public var openStub: ((AbsolutePath) throws -> ())?
    public var buildStub: ((AbsolutePath?, String?, Platform?) throws -> ())?
    
    public init() { }
    
    public func open(at path: AbsolutePath) throws {
        try openStub?(path)
    }
    
    public func build(projectPath: AbsolutePath?, schemeName: String?, sdk: Platform?) throws {
        try buildStub?(projectPath, schemeName, sdk)
    }
}
