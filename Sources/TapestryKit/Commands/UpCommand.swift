import TSCBasic
import Foundation
import TapestryGen
import ArgumentParser
import TapestryCore

/// This command initializes Swift package with example in current empty directory
struct UpCommand: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "up",
            abstract: "Sets up tapestry in given directory"
        )
    }
    
    @Option(
        name: .shortAndLong,
        help: "The path to your Swift framework"
    )
    var path: String?

    func run() throws {
        try UpService().run(
            path: path
        )
    }
}
