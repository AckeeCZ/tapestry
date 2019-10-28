import Basic
import protocol TuistCore.Command
import Foundation
import TapestryGen
import SPMUtility
import TapestryCore

/// This command initializes Swift package with example in current empty directory
final class UpCommand: NSObject, Command {
    static var command: String = "up"
    static var overview: String = "Sets up tapestry"

    let pathArgument: OptionArgument<String>
    
    required convenience init(parser: ArgumentParser) {
        self.init(parser: parser,
                  hookInstaller: HookInstaller())
    }
    
    init(parser: ArgumentParser,
         hookInstaller: HookInstalling) {
        let subParser = parser.add(subparser: GenerateCommand.command, overview: GenerateCommand.overview)
        
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to your Swift framework",
                                     completion: .filename)
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments)
        
        
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
