import Foundation
import TSCUtility
import TSCBasic
import ArgumentParser

/// Only used to provide custom `ExpressibleByArgument` implementation for `TSCUtility.Version`
struct TapestryVersion: ExpressibleByArgument {
    let version: TSCUtility.Version
    
    init?(argument: String) {
        guard let version = Version(string: argument) else { return nil }
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
    fileprivate var version: TapestryVersion
    
    @Option(
        name: .shortAndLong,
        help: "The path to the folder where the release project is located (Default: Current directory)."
    )
    var path: String?
    
    func run() throws {
        try ReleaseService().run(
            path: path,
            version: version.version
        )
    }
}
