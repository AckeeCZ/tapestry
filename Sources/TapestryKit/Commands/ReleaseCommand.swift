import Foundation
import TuistCore
import TapestryCore
import Basic
import SPMUtility

/// This command initializes Swift package with example in current empty directory
final class ReleaseCommand: NSObject, Command {
    static var command: String = "release"
    static var overview: String = "Tags a new release and updates documentation and Pod accordingly"

    let versionArgument: PositionalArgument<Int>

    private let fileHandler: FileHandling
    private let printer: TapestryCore.Printing
    private let gitController: GitControlling

    required convenience init(parser: ArgumentParser) {
        self.init(parser: parser,
                  fileHandler: FileHandler(),
                  printer: Printer(),
                  gitController: GitController())
    }

    init(parser: ArgumentParser,
         fileHandler: FileHandling,
         printer: TapestryCore.Printing,
         gitController: GitControlling) {
        let subParser = parser.add(subparser: InitCommand.command, overview: InitCommand.overview)
        versionArgument = subParser.add(positional: "Version", kind: Int.self)

        self.fileHandler = fileHandler
        self.printer = printer
        self.gitController = gitController
    }

    func run(with arguments: ArgumentParser.Result) throws {
        
    }
}
