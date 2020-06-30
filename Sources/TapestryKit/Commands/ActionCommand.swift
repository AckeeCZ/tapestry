import TSCBasic
import TapestryCore
import protocol TuistSupport.FatalError
import enum TuistSupport.ErrorType
import ArgumentParser
import Foundation

public enum Action: String, ExpressibleByArgument, CaseIterable {
    case docsUpdate = "docs-update"
    case dependenciesCompatibility = "compatibility"
}

/// Runs one of predefined actions
struct ActionCommand: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "action",
            abstract: "Run one of predefined actions"
        )
    }
    
    @Option(
        name: .shortAndLong
    )
    var path: String?
    
    @Argument(
        help: "Action you want to run"
    )
    var action: Action

    @Argument()
    var actionArguments: [String] = []
    
    func run() throws {
        try ActionService().run(
            path: path,
            action: action,
            actionArguments: actionArguments
        )
    }
}
