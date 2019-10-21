import TapestryCore
import Basic

public final class MockXcodeController: XcodeControlling {
    public var openStub: ((AbsolutePath) throws -> ())?
    
    public init() { }
    
    public func open(at path: AbsolutePath) throws {
        try openStub?(path)
    }
}
