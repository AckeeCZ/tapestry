import ArgumentParser
import TSCBasic
import TapestryCore
import Foundation

/// List all available actions
struct ActionsCommand: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "actions",
            abstract: "Show available actions"
        )
    }
    
    func run() throws {
        try ActionsService().run()
    }
}
