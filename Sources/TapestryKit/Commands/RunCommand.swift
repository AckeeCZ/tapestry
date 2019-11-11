import Basic
import TapestryCore
import TapestryGen
import protocol TuistSupport.Command
import enum TuistSupport.ErrorType
import protocol TuistSupport.FatalError
import SPMUtility
import Foundation

enum RunError: FatalError, Equatable {
    case executableCallMissing
    
    var type: ErrorType { .abort }
    
    var description: String {
        switch self {
        case .executableCallMissing:
            return "Please provide info about what to run"
        }
    }
}

/// This command initializes Swift package with example in current empty directory
final class RunCommand: NSObject, Command {
    static var command: String = "run"
    static var overview: String = "Runs executable that is defined in Tapestries/Package.swift file"

    let pathArgument: OptionArgument<String>
    let toolArguments: PositionalArgument<[String]>
    
    required init(parser: ArgumentParser) {
        let subParser = parser.add(subparser: RunCommand.command, overview: RunCommand.overview)
        
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to your Swift framework",
                                     completion: .filename)
        toolArguments = subParser.add(positional: "executable call", kind: [String].self, strategy: .remaining)
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments)
        
        guard
            let toolArguments = arguments.get(toolArguments),
            let tool = toolArguments.first
        else { throw RunError.executableCallMissing }
        
        try PackageController.shared.run(tool, arguments: Array(toolArguments.dropFirst()), path: path)
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
