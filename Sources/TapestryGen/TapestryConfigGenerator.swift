import Basic
import class TuistSupport.FileHandler
import protocol TuistSupport.FatalError
import enum TuistSupport.ErrorType
import TapestryCore

/// Interface for generating tapestries folder
public protocol TapestryConfigGenerating {
    /// Creates initial Tapestry configuration
    func generateTapestryConfig(at path: AbsolutePath) throws
}

public final class TapestryConfigGenerator: TapestryConfigGenerating {
    public init() { }
    
    public func generateTapestryConfig(at path: AbsolutePath) throws {
        let name = try PackageController.shared.name(from: path)
        let tapestryConfigPath = path.appending(component: "TapestryConfig.swift")
        try generateTapestryConfig(path: tapestryConfigPath, name: name)
    }
    
    // MARK: - Helpers
    
    private func generateTapestryConfig(path: AbsolutePath, name: String) throws {
        let contents = """
        import PackageDescription

        let config = TapestryConfig(release: Release(actions: [.pre(.docsUpdate),
                                                               .pre(.dependenciesCompatibility([.cocoapods, .carthage, .spm(.all)]))],
                                                     add: ["README.md",
                                                           "\(name).podspec",
                                                           "CHANGELOG.md"],
                                                     commitMessage: "Version \\(Argument.version)",
                                                     push: false))
        
        """
        try contents.write(to: path.url, atomically: true, encoding: .utf8)
    }
}
