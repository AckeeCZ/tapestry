import Basic
import TapestryCore
import class Workspace.InitPackage

/// Supported package types
public enum PackageType: String, CaseIterable {
    case library, executable
}

public protocol PackageGenerating {
    /// Initialize SPM package
    /// - Returns: PackageType if reading input was successful
    func initPackage(path: AbsolutePath, name: String) throws -> PackageType
}

public final class PackageGenerator: PackageGenerating {
    private let inputReader: InputReading
    
    public init(inputReader: InputReading = InputReader()) {
        self.inputReader = inputReader
    }
    
    public func initPackage(path: AbsolutePath, name: String) throws -> PackageType {
        let supportedPackageType: PackageType = try inputReader.readEnumInput(question: "Choose package type:")
        let packageType: InitPackage.PackageType
        switch supportedPackageType {
        case .library:
            packageType = .library
        case .executable:
            packageType = .executable
        }

        let initPackage = try InitPackage(name: name, destinationPath: path, packageType: packageType)
        try initPackage.writePackageStructure()

        return supportedPackageType
    }
}
