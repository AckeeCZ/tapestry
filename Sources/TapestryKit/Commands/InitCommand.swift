import Foundation
import ArgumentParser

/// This command initializes Swift package with example in current empty directory
struct InitCommand: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "init",
            abstract: "Initializes Swift package with example in current directory"
        )
    }
    
    @Option(
        name: .shortAndLong,
        help: "The path to the folder where the project will be generated (Default: Current directory)."
    )
    var path: String?

    func run() throws {
        try InitService().run(
            path: path
        )
    }
}
