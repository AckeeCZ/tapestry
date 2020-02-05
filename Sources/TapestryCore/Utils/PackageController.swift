import Basic
import protocol TuistSupport.FatalError
import enum TuistSupport.ErrorType
import struct TuistSupport.Constants
import Foundation
import SPMUtility

public enum PackageControllerError: FatalError, Equatable {
    case ungettableProjectName(AbsolutePath)
    
    public var type: ErrorType { .abort }
    
    public var description: String {
        switch self {
        case let .ungettableProjectName(path):
            return "Couldn't infer the project name from path \(path.pathString)"
        }
    }
    
    public static func == (lhs: PackageControllerError, rhs: PackageControllerError) -> Bool {
        switch (lhs, rhs) {
        case let (.ungettableProjectName(lhsPath), .ungettableProjectName(rhsPath)):
            return lhsPath == rhsPath
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
    
    public init() {}
    
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
    
    public func name(from path: AbsolutePath) throws -> String {
        if let name = path.components.last {
            return name
        } else {
            throw PackageControllerError.ungettableProjectName(AbsolutePath.current)
        }
    }
}
