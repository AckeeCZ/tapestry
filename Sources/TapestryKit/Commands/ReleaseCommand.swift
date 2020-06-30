import Foundation
import TSCUtility
import TSCBasic
import ArgumentParser

/// Only used to provide custom `ExpressibleByArgument` implementation for `TSCUtility.Version`
private struct Version: ExpressibleByArgument {
    let version: TSCUtility.Version
    
    init?(argument: String) {
        guard let version = TSCUtility.Version(string: argument) else { return nil }
        self.version = version
    }
}

/// This command initializes Swift package with example in current empty directory
struct ReleaseCommand: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "release",
            abstract: "Runs release steps defined in `TapestryConfig.swift` file"
        )
    }
    
    @Argument()
    fileprivate var version: Version
    
    @Option(
        name: .shortAndLong,
        help: "The path to the folder where the project will be generated (Default: Current directory)."
    )
    var path: String?
    
    func run() throws {
        try ReleaseService().run(
            path: path,
            version: version.version
        )
    }
}
