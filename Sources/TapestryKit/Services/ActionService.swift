import TSCBasic
import TapestryCore
import protocol TuistSupport.FatalError
import enum TuistSupport.ErrorType
import Foundation
import TapestryGen
import TSCUtility

enum ActionError: FatalError, Equatable {
    case versionInvalid
    case dependenciesInvalid
    
    var type: ErrorType { .abort }
    
    var description: String {
        switch self {
        case .versionInvalid:
            return "Please provide version in the format of major.minor.patch (0.0.1)"
        case .dependenciesInvalid:
            return "Please provide dependencies - carthage, spm, cocoapods"
        }
    }
}

final class ActionService {
    private let docsUpdater: DocsUpdating
    private let dependenciesCompatibilityChecker: DependenciesCompatibilityChecking
    
    init(
        docsUpdater: DocsUpdating = DocsUpdater(),
        dependenciesCompatibilityChecker: DependenciesCompatibilityChecking = DependenciesCompatibilityChecker()
    ) {
        self.docsUpdater = docsUpdater
        self.dependenciesCompatibilityChecker = dependenciesCompatibilityChecker
    }
    
    func run(
        path: String?,
        action: Action,
        actionArguments: [String]
    ) throws {
        let path = self.path(path)
        
        try runAction(action, path: path, actionArguments: actionArguments)
    }
    
    // MARK: - Helpers
    
    /// Runs given action
    /// - Parameters:
    ///     - action: Action to run
    ///     - path: Path where to run action from
    ///     - arguments: Arguments for `action`
    private func runAction(_ action: Action, path: AbsolutePath, actionArguments: [String]) throws {
        switch action {
        case .docsUpdate:
            guard
                actionArguments.count == 1,
                let version = Version(string: actionArguments[0])
                else { throw ActionError.versionInvalid }
            try docsUpdater.updateDocs(path: path, version: version)
            Printer.shared.print(success: "Docs updated ✅")
        case .dependenciesCompatibility:
            guard actionArguments.count > 0 else { throw ActionError.dependenciesInvalid }
            // TODO: Add spm device support
            let managers: [ReleaseAction.DependenciesManager] = try actionArguments.map {
                switch $0 {
                case "cocoapods":
                    return .cocoapods
                case "carthage":
                    return .carthage
                case "spm":
                    return .spm(.all)
                default:
                    throw ActionError.dependenciesInvalid
                }
            }
            
            try dependenciesCompatibilityChecker.checkCompatibility(with: managers, path: path)
            
            Printer.shared.print(success: "Compatible with \(actionArguments.joined(separator: ", ")) ✅")
        }
    }
    
    private func path(_ path: String?) -> AbsolutePath {
        if let path = path {
            return AbsolutePath(path, relativeTo: FileHandler.shared.currentPath)
        } else {
            return FileHandler.shared.currentPath
        }
    }
}
