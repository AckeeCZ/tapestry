import Basic

/// Interact with xcode CLI tools
public protocol XcodeControlling {
    /// Opens file with xcode
    /// - Parameters:
    ///     - path: Describes path of the file to open
    func open(at path: AbsolutePath) throws
}

/// Interact with xcode CLI tools
public final class XcodeController: XcodeControlling {
    /// Shared instance
    public static var shared: XcodeControlling = XcodeController()
    
    public func open(at path: AbsolutePath) throws {
        try System.shared.run("xed", path.pathString)
    }
}
