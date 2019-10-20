import Basic
import TapestryCore
import class TuistCore.System
import class TuistCore.Constants
import Foundation

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
    
    func run(_ tool: String, arguments: [String], path: AbsolutePath) throws
}

/// Class that access underlying swift package commands
public final class PackageController: PackageControlling {
    private let inputReader: InputReading

    public init(inputReader: InputReading = InputReader()) {
        self.inputReader = inputReader
    }
    
    public func initPackage(path: AbsolutePath, name: String) throws -> PackageType {
        let supportedPackageType: PackageType = try inputReader.readEnumInput(question: "Choose package type:")

        try System.shared.run(["swift", "package", "--package-path", path.pathString, "init", "--type" , "\(supportedPackageType.rawValue)"])

        return supportedPackageType
    }
    
    public func generateXcodeproj(path: AbsolutePath) throws {
        try System.shared.run(["swift", "package", "--package-path", path.pathString, "generate-xcodeproj"])
    }
    
    public func run(_ tool: String, arguments: [String], path: AbsolutePath) throws {
        let tapestriesPath = path.appending(component: "Tapestries")
        
        // Print if errored
        try FileHandler.shared.inDirectory(tapestriesPath) {
            try System.shared.run(["swift", "build"])
            try System.shared.run(["swift", "run", tool])
        }
        
        var environment = ProcessInfo.processInfo.environment
        environment[Constants.EnvironmentVariables.colouredOutput] = "true"
        // TODO: Candidates (Linux)
        let toolPath = path.appending(component: tool)
        try FileHandler.shared.copy(from: tapestriesPath.appending(RelativePath(".build/x86_64-apple-macosx/debug/\(tool)")), to: toolPath)
        
        defer { try? FileHandler.shared.delete(toolPath) }
        
        try FileHandler.shared.inDirectory(path) {
            try System.shared.runAndPrint([toolPath.pathString] + arguments,
                                   verbose: false,
                                   environment: environment)
        }
    }
}
