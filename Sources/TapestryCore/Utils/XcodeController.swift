import Basic

/// Device for building
public enum Device {
    case iOS(String)
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
    ///     - destination: Destination device
    func build(projectPath: AbsolutePath?, schemeName: String?, destination: Device?) throws
}

/// Interact with xcode CLI tools
public final class XcodeController: XcodeControlling {
    /// Shared instance
    public static var shared: XcodeControlling = XcodeController()
    
    public func open(at path: AbsolutePath) throws {
        try System.shared.run("xed", path.pathString)
    }
    
    public func build(projectPath: AbsolutePath?, schemeName: String?, destination: Device?) throws {
        var arguments: [String] = ["xcodebuild"]
        if let projectPath = projectPath {
            arguments += ["-project", projectPath.pathString]
        }
        if let schemeName = schemeName {
            arguments += ["-scheme", schemeName]
        }
        if let destination = destination {
            switch destination {
            case let .iOS(name):
                arguments += ["-sdk", "iphonesimulator"]
            }
        }
        Printer.shared.print(arguments.joined(separator: " "))
        try System.shared.runAndPrint(arguments)
    }
}
