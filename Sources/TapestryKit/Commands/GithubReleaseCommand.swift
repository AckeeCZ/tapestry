import Foundation
import ArgumentParser

struct GithubReleaseCommand: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "github-release",
            abstract: "Release a new version leveraging Github actions"
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
        try GithubReleaseService().run(
            path: path,
            version: version.version
        )
    }
}
