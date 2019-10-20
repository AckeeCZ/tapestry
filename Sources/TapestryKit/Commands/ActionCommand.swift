import Basic
import TapestryCore
import protocol TuistCore.Command
import protocol TuistCore.FatalError
import enum TuistCore.ErrorType
import class TuistCore.System
import SPMUtility
import Foundation
import TapestryGen

enum ActionError: FatalError {
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

public enum Action: String, ArgumentKind {
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

/// This command initializes Swift package with example in current empty directory
final class ActionCommand: NSObject, Command {
    static var command: String = "action"
    static var overview: String = "Run one of predefined actions."

    let pathArgument: OptionArgument<String>
    let actionArgument: PositionalArgument<Action>
    let actionArguments: PositionalArgument<[String]>
    
    private let docsUpdater: DocsUpdating
    private let dependenciesCompatibilityChecker: DependenciesComptabilityChecking
    
    required convenience init(parser: ArgumentParser) {
        self.init(parser: parser,
                  docsUpdater: DocsUpdater(),
                  dependenciesCompatibilityChecker: DependenciesComptabilityChecker())
    }
    
    init(parser: ArgumentParser,
         docsUpdater: DocsUpdating,
         dependenciesCompatibilityChecker: DependenciesComptabilityChecking) {
        let subParser = parser.add(subparser: ActionCommand.command, overview: ActionCommand.overview)
        
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path where to run action from.",
                                     completion: .filename)
        actionArgument = subParser.add(positional: "tapestry action", kind: Action.self)
        actionArguments = subParser.add(positional: "tapestry action arguments", kind: [String].self, strategy: .upToNextOption)
        
        self.docsUpdater = docsUpdater
        self.dependenciesCompatibilityChecker = dependenciesCompatibilityChecker
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments)
        guard let action = arguments.get(actionArgument) else { fatalError() }
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
    
    // TODO: Share between commands
    /// Obtain package path
    private func path(arguments: ArgumentParser.Result) throws -> AbsolutePath {
        if let path = arguments.get(pathArgument) {
            return AbsolutePath(path, relativeTo: FileHandler.shared.currentPath)
        } else {
            return FileHandler.shared.currentPath
        }
    }
}

public protocol DocsUpdating {
    func updateDocs(path: AbsolutePath, version: Version) throws
}

public final class DocsUpdater: DocsUpdating {
    public func updateDocs(path: AbsolutePath, version: Version) throws {
        let name = try self.name(path: path)
        
        Printer.shared.print("Updating docs 📚")
        
        try updateVersionInPodspec(path: path,
                           name: name,
                           version: version)
        
        try updateVersionInReadme(path: path,
                                  name: name,
                                  version: version)
    }
    
    // MARK: - Helpers
    
    private func updateVersionInPodspec(path: AbsolutePath,
                                        name: String,
                                        version: Version) throws {
        let podspecPath = path.appending(component: "\(name).podspec")
        guard FileHandler.shared.exists(podspecPath) else {
            Printer.shared.print(warning: "Podspec at \(podspecPath.pathString) does not exist, skipping...")
            return
        }
        var content = try FileHandler.shared.readTextFile(podspecPath)
        content = content.replacingOccurrences(
            of: #"s\.version = \"(([0-9]|[\.])*)\""#,
            with: "s.version = \"\(version.description)\"",
            options: .regularExpression
        )
        try content.write(to: podspecPath.url, atomically: true, encoding: .utf8)
    }
    
    private func updateVersionInReadme(path: AbsolutePath,
                                       name: String,
                                       version: Version) throws {
        let readmePath = path.appending(component: "README.md")
        guard FileHandler.shared.exists(readmePath) else {
            Printer.shared.print(warning: "Podspec at \(readmePath.pathString) does not exist, skipping...")
            return
        }
        var content = try FileHandler.shared.readTextFile(readmePath)
        // Replacing pods version
        content = content
        .replacingOccurrences(
            of: "pod \"\(name)\"" + #", "~>[ ]?([0-9]|[\.])*""#,
            with: "pod \"\(name)\", \"~> \(version.description)\"",
            options: .regularExpression
        )
        // Replacing SPM version
        .replacingOccurrences(
            of: "\(name)" + #"\.git", \.upToNextMajor\(from:[ ]?"([0-9]|[\.])*""#,
            with: "\(name).git\", .upToNextMajor(from: \"\(version.description)\"",
            options: .regularExpression
        )

        try content.write(to: readmePath.url, atomically: true, encoding: .utf8)
    }
    
    
    /// Obtain package name
    /// - Parameters:
    ///     - path: Name is derived from this path (last component)
    private func name(path: AbsolutePath) throws -> String {
        if let name = path.components.last {
            return name
        } else {
            throw InitCommandError.ungettableProjectName(AbsolutePath.current)
        }
    }
}
