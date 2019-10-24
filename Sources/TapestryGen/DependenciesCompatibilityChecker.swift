import Basic
import TapestryCore
import protocol TuistCore.FatalError
import enum TuistCore.ErrorType

enum DependenciesCompatibilityError: FatalError {
    case carthage
    case cocoapods
    case spmBuild
    case xcodeBuild(String)
    
    var type: ErrorType { .abort }
    
    var description: String {
        switch self {
        case .carthage:
            return "Carthage compatibility check failed - try running carthage build --no-skip-current to debug"
        case .cocoapods:
            return "Cocoapods compatibility check failed - try running pod lib lint to debug"
        case .spmBuild:
            return "SPM compatibility check failed - try running swift build to debug"
        case let .xcodeBuild(name):
            return """
            Try running "swift package generate-xcodeproj --output spm_compatibility.xcodeproj && xcodebuild -project spm_compatibility.xcodeproj -scheme \(name)-Package -sdk iphonesimulator | rm -r spm_compatibility.xcodeproj"
            """
        }
    }
}

/// Check compatibility with various dependency managers
public protocol DependenciesCompatibilityChecking {
    /// Check compatibility with given dependency managers
    /// - Parameters:
    ///     - dependenciesManagers: Set of managers to check
    ///     - path: Where to check the managers from
    /// - Throws: Error if some compatibility check fails
    func checkCompatibility(with dependenciesManagers: [ReleaseAction.DependenciesManager], path: AbsolutePath) throws
}

public final class DependenciesCompatibilityChecker: DependenciesCompatibilityChecking {
    public init() { }
    
    public func checkCompatibility(with dependenciesManagers: [ReleaseAction.DependenciesManager], path: AbsolutePath) throws {
        try dependenciesManagers.forEach {
            switch $0 {
            case .carthage:
                try checkCarthageCompatibility(path: path)
            case .cocoapods:
                try checkCocoapodsCompatibility(path: path)
            case let .spm(platform):
                try checkSPMCompatibility(path: path, platform: platform)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func checkCarthageCompatibility(path: AbsolutePath) throws {
        Printer.shared.print("Checking Carthage compatibility...")
        try FileHandler.shared.inDirectory(path) {
            do {
                try System.shared.run(["carthage", "build", "--no-skip-current"])
            } catch {
                throw DependenciesCompatibilityError.carthage
            }
        }
    }
    
    private func checkCocoapodsCompatibility(path: AbsolutePath) throws {
        Printer.shared.print("Checking Cococapods compatibility...")
        try FileHandler.shared.inDirectory(path) {
            do {
                try System.shared.run(["pod", "lib", "lint"])
            } catch {
                throw DependenciesCompatibilityError.cocoapods
            }
        }
    }
    
    private func checkSPMCompatibility(path: AbsolutePath, platform: ReleaseAction.Platform) throws {
        Printer.shared.print("Checking SPM compatibility...")
        try FileHandler.shared.inDirectory(path) {
            switch platform {
            case .iOS:
                let name = try PackageController.shared.name(from: path)
                do {
                    let projectPath = path.appending(component: "spm_compatibility.xcodeproj")
                    defer { try? FileHandler.shared.delete(projectPath) }
                    try PackageController.shared.generateXcodeproj(path: path, output: projectPath)
                    try XcodeController.shared.build(projectPath: projectPath, schemeName: name + "-Package", sdk: .iOS)
                } catch {
                    throw DependenciesCompatibilityError.xcodeBuild(name)
                }
            case .all:
                do {
                    System.shared.run(["swift", "build"])
                } catch {
                    throw DependenciesCompatibilityError.spmBuild
                }
                
            }
        }
    }
}
