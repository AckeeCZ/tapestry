import Basic
import class TuistCore.Constants
import protocol TuistCore.FatalError
import enum TuistCore.ErrorType
import class TuistCore.Constants
import Foundation
import SPMUtility

public enum PackageControllerError: FatalError, Equatable {
    case ungettableProjectName(AbsolutePath)
    case buildFailed(String)
    
    public var type: ErrorType { .abort }
    
    public var description: String {
        switch self {
        case let .ungettableProjectName(path):
            return "Couldn't infer the project name from path \(path.pathString)"
        case let .buildFailed(tool):
            return "Building \(tool) failed - try running `swift run --package-path Tapestries \(tool)` to debug"
        }
    }
    
    public static func == (lhs: PackageControllerError, rhs: PackageControllerError) -> Bool {
        switch (lhs, rhs) {
        case let (.ungettableProjectName(lhsPath), .ungettableProjectName(rhsPath)):
            return lhsPath == rhsPath
        case let (.buildFailed(lhsTool), .buildFailed(rhsTool)):
            return lhsTool == rhsTool
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
    func generateXcodeproj(path: AbsolutePath, output: AbsolutePath?) throws
    
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
    /// Updates packages
    /// - Parameters:
    ///     - path: Name is derived from this path (last component)
    func update(path: AbsolutePath) throws
}

extension PackageControlling {
    public func generateXcodeproj(path: AbsolutePath) throws {
        try generateXcodeproj(path: path, output: nil)
    }
}

/// Class that access underlying swift package commands
public final class PackageController: PackageControlling {
    /// Shared instance
    public static var shared: PackageControlling = PackageController()
    
    public func update(path: AbsolutePath) throws {
        try System.shared.runAndPrint(["swift", "package", "--package-path", path.pathString, "update"])
    }
    
    public func initPackage(path: AbsolutePath, name: String) throws -> PackageType {
        let supportedPackageType: PackageType = try InputReader.shared.readEnumInput(question: "Choose package type:")

        try System.shared.run(["swift", "package", "--package-path", path.pathString, "init", "--type" , "\(supportedPackageType.rawValue)"])

        return supportedPackageType
    }
    
    public func generateXcodeproj(path: AbsolutePath, output: AbsolutePath?) throws {
        var arguments = ["swift", "package", "--package-path", path.pathString, "generate-xcodeproj"]
        if let output = output {
            arguments += ["--output", output.pathString]
        }
        try System.shared.run(arguments)
    }
    
    public func run(_ tool: String, arguments: [String], path: AbsolutePath) throws {
        let tapestriesPath = path.appending(component: Constants.tapestriesName)
        
        try FileHandler.shared.inDirectory(tapestriesPath) {
            do {
                try swiftRunTool(tool)
            } catch {
                throw PackageControllerError.buildFailed(tool)
            }
        }
        
        if tool == "tapestry" {
            try System.shared.run(["swift", "build", "--package-path", tapestriesPath.pathString])
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
    
    // MARK: - Helpers
    
    /// Runs tool using swift
    /// - Parameters:
    ///     - tool: Name of tool to run
    private func swiftRunTool(_ tool: String) throws {
        let progressAnimation = NinjaProgressAnimation(stream: Basic.stdoutStream)
        var downloadPrinted = false
        var animationUpdated = false
        try System.shared.runAndPrint(["swift", "run", tool],
                                      verbose: false,
                                      environment: Process.env,
                                      redirection: .stream(stdout: { bytes in
                                        // do nothing
                                      }, stderr: { bytes in
                                        guard
                                            // TODO: Enable for building other tools, too
                                            // The bug right now is that it prints updates on a new line, rather than current
                                            tool == "tapestry",
                                            let output = String(bytes: bytes, encoding: .utf8)
                                        else { return }
                                        if !downloadPrinted, output.contains("Fetching") || output.contains("Updating") {
                                            Printer.shared.print("Fetching dependencies...")
                                            downloadPrinted = true
                                            return
                                        }
                                        guard let (step, total) = self.progress(for: progressAnimation, with: output) else { return }
                                        progressAnimation.update(step: step, total: total, text: "Building \(tool)")
                                        animationUpdated = true
                                      }))
        if animationUpdated, let dataOutput = " ✅".data(using: .utf8) {
            FileHandle.standardOutput.write(dataOutput)
            progressAnimation.complete(success: true)
        }
    }
    
    /// - Returns: Returns current steps and total steps for running build action
    private func progress(for progressAnimation: NinjaProgressAnimation, with output: String) -> (Int, Int)? {
        guard let range = output.range(of: "\\[.*\\]", options: .regularExpression) else { return nil }
        let numbers = output[range]
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .split(separator: "/")
        guard
            numbers.count == 2,
            let step = Int(numbers[0]),
            let total = Int(numbers[1])
        else { return nil }
        
        return (step, total)
    }

}
