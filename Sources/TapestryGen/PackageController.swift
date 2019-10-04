import Basic
import TapestryCore
import TuistCore

/// Supported package types
public enum PackageType: String, CaseIterable {
    case library, executable
}

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
    private let system: Systeming

    public init(inputReader: InputReading = InputReader(),
                system: Systeming = System()) {
        self.inputReader = inputReader
        self.system = system
    }
    
    public func initPackage(path: AbsolutePath, name: String) throws -> PackageType {
        let supportedPackageType: PackageType = try inputReader.readEnumInput(question: "Choose package type:")

        try system.run(["swift", "package", "init", "--\(supportedPackageType.rawValue)"])

        return supportedPackageType
    }
    
    public func generateXcodeproj(path: AbsolutePath) throws {
        try system.run(["swift", "package", "--package-path", path.pathString, "generate-xcodeproj"])
    }
}
