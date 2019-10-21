import Basic
import TapestryCore
import protocol TuistCore.Command
import class TuistCore.System
import SPMUtility
import Foundation

/// This command initializes Swift package with example in current empty directory
final class EditCommand: NSObject, Command {
    static var command: String = "edit"
    static var overview: String = "Edit TapestryConfig file."

    let pathArgument: OptionArgument<String>
    
    required init(parser: ArgumentParser) {
        let subParser = parser.add(subparser: EditCommand.command, overview: EditCommand.overview)
        
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to the `Tapestry.swift` file.",
                                     completion: .filename)
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments)
        
        Printer.shared.print("""
        ✏️  Opening Tapestries project
            
        To edit `TapestryConfig` navigate to `TapestryConfig.swift`
        """)
        try System.shared.run("xed", path.pathString + "/Tapestries/")
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
