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
    
    private let configGenerator: ConfigGenerating
    
    required convenience init(parser: ArgumentParser) {
        self.init(parser: parser,
                  configGenerator: ConfigGenerator())
    }
    
    init(parser: ArgumentParser,
         configGenerator: ConfigGenerating) {
        let subParser = parser.add(subparser: EditCommand.command, overview: EditCommand.overview)
        
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to the `Tapestry.swift` file.",
                                     completion: .filename)
        
        self.configGenerator = configGenerator
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments)
        let name = try self.name(path: path)
        
        try configGenerator.generateProject(path: path,
                                             name: name,
                                             bundleId: "tapestry")
        
        Printer.shared.print("""
        ✏️  Opening \(name)\(ConfigGenerator.configFilename).xcodeproj/
            
        Press the return key once you're done
        """)
        try System.shared.run("open", "\(name)\(ConfigGenerator.configFilename).xcodeproj/")
        readLine(until: .whitespacesAndNewlines)
        try FileHandler.shared.delete(path.appending(RelativePath("\(name)\(ConfigGenerator.configFilename).xcodeproj/")))
    }
    
    private func readLine(until characterSet: CharacterSet) {
        if (Swift.readLine() ?? "").rangeOfCharacter(from: characterSet) != nil {
            readLine(until: characterSet)
        }
    }
    
    // TODO: Share between commands
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
    
    /// Obtain package path
    private func path(arguments: ArgumentParser.Result) throws -> AbsolutePath {
        if let path = arguments.get(pathArgument) {
            return AbsolutePath(path, relativeTo: FileHandler.shared.currentPath)
        } else {
            return FileHandler.shared.currentPath
        }
    }
}
