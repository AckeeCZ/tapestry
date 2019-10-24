import TapestryCore
import Basic

public final class MockXcodeController: XcodeControlling {
    public var openStub: ((AbsolutePath) throws -> ())?
    public var buildStub: ((AbsolutePath?, String?, Device?) throws -> ())?
    
    public init() { }
    
    public func open(at path: AbsolutePath) throws {
        try openStub?(path)
    }
    
    public func build(projectPath: AbsolutePath?, schemeName: String?, destination: Device?) throws {
        try buildStub?(projectPath, schemeName, destination)
    }
}
