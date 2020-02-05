import Basic
import protocol TuistSupport.Command
import Foundation
import TapestryGen
import SPMUtility
import TapestryCore

/// This command initializes Swift package with example in current empty directory
final class UpCommand: NSObject, Command {
    static var command: String = "up"
    static var overview: String = "Sets up tapestry in given directory"

    let pathArgument: OptionArgument<String>
    private let tapestryConfigGenerator: TapestryConfigGenerating
    
    required convenience init(parser: ArgumentParser) {
        self.init(parser: parser,
                  tapestryConfigGenerator: TapestryConfigGenerator())
    }
    
    init(parser: ArgumentParser,
         tapestryConfigGenerator: TapestryConfigGenerating) {
        let subParser = parser.add(subparser: UpCommand.command, overview: UpCommand.overview)
        
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to your Swift framework",
                                     completion: .filename)
        
        self.tapestryConfigGenerator = tapestryConfigGenerator
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments)
        
        Printer.shared.print("Generating tapestry config 🎨")
        
        try tapestryConfigGenerator.generateTapestryConfig(at: path)
        
        Printer.shared.print(success: "Generation succeeded! ✅")
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
