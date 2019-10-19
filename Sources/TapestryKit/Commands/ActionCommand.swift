import Basic
import TapestryCore
import protocol TuistCore.Command
import class TuistCore.System
import SPMUtility
import Foundation

public enum Action: String, ArgumentKind {
    case docsUpdate = "docs-update"
    
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
    
    required convenience init(parser: ArgumentParser) {
        self.init(parser: parser,
                  docsUpdater: DocsUpdater())
    }
    
    init(parser: ArgumentParser,
         docsUpdater: DocsUpdating) {
        let subParser = parser.add(subparser: ActionCommand.command, overview: ActionCommand.overview)
        
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path where to run action from.",
                                     completion: .filename)
        actionArgument = subParser.add(positional: "tapestry action", kind: Action.self)
        actionArguments = subParser.add(positional: "tapestry action arguments", kind: [String].self, strategy: .upToNextOption)
        
        self.docsUpdater = docsUpdater
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
            else { fatalError() }
            try docsUpdater.updateDocs(path: path, version: version)
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

protocol DocsUpdating {
    func updateDocs(path: AbsolutePath, version: Version) throws
}

public final class DocsUpdater: DocsUpdating {
    func updateDocs(path: AbsolutePath, version: Version) throws {
        let name = try self.name(path: path)
        
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
