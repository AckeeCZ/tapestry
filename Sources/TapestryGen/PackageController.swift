import Basic
import TapestryCore
import TuistCore

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
}
