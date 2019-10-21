import Basic
import class TuistCore.FileHandler
import protocol TuistCore.FatalError
import enum TuistCore.ErrorType
import TapestryCore

enum TapestriesGeneratorError: FatalError, Equatable {
    case tapestriesFolderExists(AbsolutePath)
    
    var type: ErrorType { .abort }
    
    var description: String {
        switch self {
        case let .tapestriesFolderExists(path):
            return "Tapestries folder at path \(path.pathString) already exists"
        }
    }
}

/// Interface for generating tapestries folder
public protocol TapestriesGenerating {
    /// Creates Tapestries folder
    /// There are defined local tapestry, developer dependencies and TapestryConfig
    func generateTapestries(at path: AbsolutePath) throws
}

public final class TapestriesGenerator: TapestriesGenerating {
    public init() { }
    
    public func generateTapestries(at path: AbsolutePath) throws {
        let tapestriesPath = path.appending(component: "Tapestries")
        guard !FileHandler.shared.exists(tapestriesPath) else { throw TapestriesGeneratorError.tapestriesFolderExists(tapestriesPath) }
        let tapestryConfigPath = tapestriesPath.appending(RelativePath("Sources/TapestryConfig"))
        try FileHandler.shared.createFolder(tapestryConfigPath)
        
        try generatePackageManifest(path: tapestriesPath)
        try generateTapestryConfig(path: tapestryConfigPath)
    }
    
    // MARK: - Helpers
    
    private func generatePackageManifest(path: AbsolutePath) throws {
        let contents = """
        // swift-tools-version:\(Constants.swiftVersion)
        // The swift-tools-version declares the minimum version of Swift required to build this package.

        import PackageDescription

        let package = Package(
            name: "Tapestries",
            products: [
            .library(name: "TapestryConfig", targets: ["TapestryConfig"])
            ],
            dependencies: [
                // Tapestry
                .package(url: "\(Constants.gitRepositoryURL)", .upToNextMajor(from: "\(Constants.version)")),
                .package(url: "https://github.com/nicklockwood/SwiftFormat", .upToNextMajor(from: "0.40.13")),
            ],
            targets: [
                .target(name: "TapestryConfig",
                        dependencies: [
                            "PackageDescription"
                ])
            ]
        )
        """
        try contents.write(to: path.appending(component: "Package.swift").url, atomically: true, encoding: .utf8)
    }
    
    private func generateTapestryConfig(path: AbsolutePath) throws {
        let contents = """
        import PackageDescription

        let config = TapestryConfig(release: Release(actions: [.pre(.docsUpdate),
                                                               .pre(.run(tool: "swiftformat", arguments: ["."])),
                                                               .pre(.dependenciesCompatibility([.cocoapods, .carthage, .spm]))],
                                                     add: ["README.md", "TapestryDemo.podspec"],
                                                     commitMessage: "Version \\(Argument.version)",
                                                     push: true))
        """
        try contents.write(to: path.appending(component: "TapestryConfig.swift").url, atomically: true, encoding: .utf8)
    }
}
