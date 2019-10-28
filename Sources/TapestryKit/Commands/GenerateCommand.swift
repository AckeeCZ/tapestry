import Basic
import protocol TuistCore.Command
import Foundation
import TapestryGen
import SPMUtility
import TapestryCore

/// This command initializes Swift package with example in current empty directory
final class GenerateCommand: NSObject, Command {
    static var command: String = "generate"
    static var overview: String = "Generates tapestry in given directory"

    let pathArgument: OptionArgument<String>
    private let tapestriesGenerator: TapestriesGenerating
    
    required convenience init(parser: ArgumentParser) {
        self.init(parser: parser,
                  tapestriesGenerator: TapestriesGenerator())
    }
    
    init(parser: ArgumentParser,
         tapestriesGenerator: TapestriesGenerating) {
        let subParser = parser.add(subparser: GenerateCommand.command, overview: GenerateCommand.overview)
        
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to your Swift framework",
                                     completion: .filename)
        
        self.tapestriesGenerator = tapestriesGenerator
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments)
        
        Printer.shared.print("Generating tapestry 🎨")
        
        try tapestriesGenerator.generateTapestries(at: path)
        
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
