import Basic
import TapestryCore
import protocol TuistCore.Command
import protocol TuistCore.FatalError
import enum TuistCore.ErrorType
import class TuistCore.System
import SPMUtility
import Foundation
import TapestryGen

enum ActionError: FatalError, Equatable {
    case versionInvalid
    case dependenciesInvalid
    case actionMissing
    
    var type: ErrorType { .abort }
    
    var description: String {
        switch self {
        case .versionInvalid:
            return "Please provide version in the format of major.minor.patch (0.0.1)"
        case .dependenciesInvalid:
            return "Please provide dependencies - carthage, spm, cocoapods"
        case .actionMissing:
            return "You must provide action name"
        }
    }
}

public enum Action: String, ArgumentKind, CaseIterable {
    case docsUpdate = "docs-update"
    case dependenciesCompatibility = "compatibility"
    
    public init(argument: String) throws {
        guard let action = Action(rawValue: argument) else {
            throw ArgumentConversionError.typeMismatch(value: argument, expectedType: Action.self)
        }

        self = action
    }
    
    public static let completion: ShellCompletion = .none
}

/// Runs one of predefined actions
final class ActionCommand: NSObject, Command {
    static var command: String = "action"
    static var overview: String = "Run one of predefined actions"

    let pathArgument: OptionArgument<String>
    let actionArgument: PositionalArgument<Action>
    // TODO: Rewrite this, this does not allow actions with no arguments
    let actionArguments: PositionalArgument<[String]>
    
    private let docsUpdater: DocsUpdating
    private let dependenciesCompatibilityChecker: DependenciesCompatibilityChecking
    
    required convenience init(parser: ArgumentParser) {
        self.init(parser: parser,
                  docsUpdater: DocsUpdater(),
                  dependenciesCompatibilityChecker: DependenciesCompatibilityChecker())
    }
    
    init(parser: ArgumentParser,
         docsUpdater: DocsUpdating,
         dependenciesCompatibilityChecker: DependenciesCompatibilityChecking) {
        let subParser = parser.add(subparser: ActionCommand.command, overview: ActionCommand.overview)
        
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path where to run action from.",
                                     completion: .filename)
        actionArgument = subParser.add(positional: "action", kind: Action.self)
        actionArguments = subParser.add(positional: "action arguments", kind: [String].self, strategy: .upToNextOption)
        
        self.docsUpdater = docsUpdater
        self.dependenciesCompatibilityChecker = dependenciesCompatibilityChecker
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments)
        
        guard let action = arguments.get(actionArgument) else { throw ActionError.actionMissing }
        try runAction(action, path: path, arguments: arguments)
    }
    
    // MARK: - Helpers
    
    /// Runs given action
    /// - Parameters:
    ///     - action: Action to run
    ///     - path: Path where to run action from
    ///     - arguments: Arguments for `action`
    private func runAction(_ action: Action, path: AbsolutePath, arguments: ArgumentParser.Result) throws {
        switch action {
        case .docsUpdate:
            guard
                let actionArguments = arguments.get(self.actionArguments),
                actionArguments.count == 1,
                let version = Version(string: actionArguments[0])
            else { throw ActionError.versionInvalid }
            try docsUpdater.updateDocs(path: path, version: version)
            Printer.shared.print(success: "Docs updated ✅")
        case .dependenciesCompatibility:
            guard
                let actionArguments = arguments.get(self.actionArguments),
                actionArguments.count > 0
            else { throw ActionError.dependenciesInvalid }
            let managers: [ReleaseAction.DependenciesManager] = try actionArguments.map {
                guard let manager = ReleaseAction.DependenciesManager(rawValue: $0) else { throw ActionError.dependenciesInvalid }
                return manager
            }
            
            try dependenciesCompatibilityChecker.checkCompatibility(with: managers, path: path)
            
            Printer.shared.print(success: "Compatible with \(managers.map { $0.rawValue }.joined(separator: ", ")) ✅")
        }
    }
    
    /// Obtain package path
    private func path(arguments: ArgumentParser.Result) throws -> AbsolutePath {
        if let path = arguments.get(pathArgument) {
            return AbsolutePath(path, relativeTo: FileHandler.shared.currentPath)
        } else {
            return FileHandler.shared.currentPath
        }
    }
}
