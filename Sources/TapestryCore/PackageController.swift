import Basic
import class TuistCore.System
import class TuistCore.Constants
import protocol TuistCore.FatalError
import enum TuistCore.ErrorType
import class TuistCore.Constants
import Foundation

enum PackageControllerError: FatalError, Equatable {
    case ungettableProjectName(AbsolutePath)
    
    var type: ErrorType { .abort }
    
    var description: String {
        switch self {
        case let .ungettableProjectName(path):
            return "Couldn't infer the project name from path \(path.pathString)"
        }
    }
    
    static func == (lhs: PackageControllerError, rhs: PackageControllerError) -> Bool {
        switch (lhs, rhs) {
        case let (.ungettableProjectName(lhsPath), .ungettableProjectName(rhsPath)):
            return lhsPath == rhsPath
        default:
            return false
        }
    }
}

/// Supported package types
public enum PackageType: String, CaseIterable {
    case library, executable
}

/// Interrface for interacting wit Swift package
public protocol PackageControlling {
    /// Initialize SPM package
    /// - Parameters:
    ///     -  path: Path where should package be created
    ///     -  name:
    /// - Returns: PackageType if reading input was successful
    func initPackage(path: AbsolutePath, name: String) throws -> PackageType
    
    /// Generate Xcodeproj for package at given path
    /// - Parameters:
    ///     - path: The path of package we should generate xcodeproj for
    func generateXcodeproj(path: AbsolutePath) throws
    
    /// Runs tool using tapestry
    /// - Parameters:
    ///     - tool: Name of tool to run
    ///     - arguments: Arguments to pass to tool
    ///     - path: Where should this be run from
    func run(_ tool: String, arguments: [String], path: AbsolutePath) throws
    
    /// Obtain package name
    /// - Parameters:
    ///     - path: Name is derived from this path (last component)
    func name(from path: AbsolutePath) throws -> String
}

/// Class that access underlying swift package commands
public final class PackageController: PackageControlling {
    /// Shared instance
    public static var shared: PackageControlling = PackageController()
    
    public func initPackage(path: AbsolutePath, name: String) throws -> PackageType {
        let supportedPackageType: PackageType = try InputReader.shared.readEnumInput(question: "Choose package type:")

        try System.shared.run(["swift", "package", "--package-path", path.pathString, "init", "--type" , "\(supportedPackageType.rawValue)"])

        return supportedPackageType
    }
    
    public func generateXcodeproj(path: AbsolutePath) throws {
        try System.shared.run(["swift", "package", "--package-path", path.pathString, "generate-xcodeproj"])
    }
    
    public func run(_ tool: String, arguments: [String], path: AbsolutePath) throws {
        let tapestriesPath = path.appending(component: "Tapestries")
        
        // TODO: Show progress without cluttering command line
        
        try FileHandler.shared.inDirectory(tapestriesPath) {
            try System.shared.runAndPrint(["swift", "run", tool])
        }
        
        // TODO: Candidates (Linux)
        let toolPath = path.appending(component: tool)
        
        try? FileHandler.shared.delete(toolPath)
        try FileHandler.shared.copy(from: tapestriesPath.appending(RelativePath(".build/x86_64-apple-macosx/debug/\(tool)")), to: toolPath)
        
        defer { try? FileHandler.shared.delete(toolPath) }
        
        try FileHandler.shared.inDirectory(path) {
            var environment = ProcessInfo.processInfo.environment
            environment[TuistCore.Constants.EnvironmentVariables.colouredOutput] = "true"
            try System.shared.runAndPrint([toolPath.pathString] + arguments,
                                   verbose: false,
                                   environment: environment)
        }
    }
    
    public func name(from path: AbsolutePath) throws -> String {
        if let name = path.components.last {
            return name
        } else {
            throw PackageControllerError.ungettableProjectName(AbsolutePath.current)
        }
    }

}
