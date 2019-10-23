import Basic
import TapestryCore

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
            case .spm:
                try checkSPMCompatibility(path: path)
            }
        }
    }
    
    // MARK: - Helpers
    
    // TODO: Print only if failed
    
    private func checkCarthageCompatibility(path: AbsolutePath) throws {
        Printer.shared.print("Checking Carthage compatibility...")
        try FileHandler.shared.inDirectory(path) {
            try System.shared.runAndPrint(["carthage", "build", "--no-skip-current"])
        }
    }
    
    private func checkCocoapodsCompatibility(path: AbsolutePath) throws {
        Printer.shared.print("Checking Cococapods compatibility...")
        try FileHandler.shared.inDirectory(path) {
            try System.shared.runAndPrint(["pod", "lib", "lint"])
        }
    }
    
    private func checkSPMCompatibility(path: AbsolutePath) throws {
        Printer.shared.print("Checking SPM compatibility...")
        try FileHandler.shared.inDirectory(path) {
            try System.shared.runAndPrint(["swift", "build"])
        }
    }
}
