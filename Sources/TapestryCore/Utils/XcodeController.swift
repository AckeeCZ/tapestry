import TSCBasic

/// Platform for building
public enum Platform {
    case iOS
}

/// Interact with xcode CLI tools
public protocol XcodeControlling {
    /// Opens file with xcode
    /// - Parameters:
    ///     - path: Describes path of the file to open
    func open(at path: AbsolutePath) throws
    
    /// Runs xcodebuild
    /// - Parameters:
    ///     - projectPath: Path to the xcodeproj to build
    ///     - scheme: Name of scheme to build
    ///     - sdk: Which platform's SDK to use
    func build(projectPath: AbsolutePath?, schemeName: String?, sdk: Platform?) throws
}

/// Interact with xcode CLI tools
public final class XcodeController: XcodeControlling {
    /// Shared instance
    public static var shared: XcodeControlling = XcodeController()
    
    public init() {}
    
    public func open(at path: AbsolutePath) throws {
        try System.shared.run("xed", path.pathString)
    }
    
    public func build(projectPath: AbsolutePath?, schemeName: String?, sdk: Platform?) throws {
        var arguments: [String] = ["xcodebuild"]
        if let projectPath = projectPath {
            arguments += ["-project", projectPath.pathString]
        }
        if let schemeName = schemeName {
            arguments += ["-scheme", schemeName]
        }
        if let sdk = sdk {
            switch sdk {
            case .iOS:
                arguments += ["-sdk", "iphonesimulator"]
            }
        }
        try System.shared.run(arguments)
    }
}
