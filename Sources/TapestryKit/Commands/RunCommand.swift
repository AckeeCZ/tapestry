import Basic
import TapestryCore
import protocol TuistCore.Command
import class TuistCore.System
import SPMUtility
import Foundation

/// This command initializes Swift package with example in current empty directory
final class RunCommand: NSObject, Command {
    static var command: String = "run"
    static var overview: String = "Configure developer depednencies management alongside with `TapestryConfig` to automate mundane tasks"

    // upToNextOption ArgumentType
    let pathArgument: OptionArgument<String>
    let toolArguments: PositionalArgument<[String]>
    
    required init(parser: ArgumentParser) {
        let subParser = parser.add(subparser: RunCommand.command, overview: RunCommand.overview)
        
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to your Swift framework",
                                     completion: .filename)
        toolArguments = subParser.add(positional: "tool call", kind: [String].self, strategy: .remaining)
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments)
        
        guard
            let toolArguments = arguments.get(toolArguments),
            let tool = toolArguments.first
        else { fatalError() }
        
        try System.shared.runAndPrint(["swift", "run", "--package-path", path.appending(component: "Tapestries").pathString] + toolArguments)
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
