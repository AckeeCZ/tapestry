import Basic
import class TuistCore.System

public protocol XcodeControlling {
    func open(at path: AbsolutePath) throws
}

public final class XcodeController: XcodeControlling {
    /// Shared instance
    public static var shared: XcodeControlling = XcodeController()
    
    public init() { }
    
    public func open(at path: AbsolutePath) throws {
        try System.shared.run("xed", path.pathString)
    }
}
