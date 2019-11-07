import Basic
import protocol TuistCore.Command
import Foundation
import TapestryGen
import SPMUtility
import TapestryCore

/// This command initializes Swift package with example in current empty directory
final class UpdateCommand: NSObject, Command {
    static var command: String = "update"
    static var overview: String = "Updates local tapestry and dependencies in \"Tapestries/Package.swift\""

    let pathArgument: OptionArgument<String>
    
    required init(parser: ArgumentParser) {
        let subParser = parser.add(subparser: UpdateCommand.command, overview: UpdateCommand.overview)
        
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to your Swift framework",
                                     completion: .filename)
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments)
        
        try PackageController.shared.update(path: path)
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
