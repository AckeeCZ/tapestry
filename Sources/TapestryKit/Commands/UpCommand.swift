import Basic
import TapestryCore
import protocol TuistCore.Command
import class TuistCore.System
import SPMUtility
import Foundation

/// This command initializes Swift package with example in current empty directory
final class UpCommand: NSObject, Command {
    static var command: String = "up"
    static var overview: String = "Configure developer depednencies management alongside with `TapestryConfig` to automate mundane tasks"

    let pathArgument: OptionArgument<String>
    
    required init(parser: ArgumentParser) {
        let subParser = parser.add(subparser: UpCommand.command, overview: UpCommand.overview)
        
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to your Swift framework",
                                     completion: .filename)
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments)
        
        // TODO: Check if tapestries path already exists
        
        let tapestriesPath = path.appending(component: "Tapestries")
        let configPath = tapestriesPath.appending(RelativePath("Sources/TapestryConfig"))
        try FileHandler.shared.createFolder(configPath)
        
        let contents = """
        import PackageDescription

        let config = TapestryConfig(release: ReleaseAction(add: nil,
                                                           commitMessage: nil,
                                                           push: false))
        """
        
        try contents.write(to: configPath.appending(component: "TapestryConfig.swift").url, atomically: true, encoding: .utf8)
        
        // TODO: Fix directory and swift tools version!
        let packageContents = """
        // swift-tools-version:5.1
        // The swift-tools-version declares the minimum version of Swift required to build this package.

        import PackageDescription

        let package = Package(
            name: "Tapestries",
            products: [
            .library(name: "TapestryConfig", targets: ["TapestryConfig"])
            ],
            dependencies: [
                // Tapestry
                .package(path: "/Users/marekfort/Development/ackee/tapestry"),
                .package(url: "https://github.com/nicklockwood/SwiftFormat", .upToNextMajor(from: "0.40.13")),
            ],
            targets: [
                .target(name: "TapestryConfig",
                        dependencies: [
                            "PackageDescription"
                ])
            ]
        )
        """
        try packageContents.write(to: tapestriesPath.appending(component: "Package.swift").url, atomically: true, encoding: .utf8)
    }
    
    // TODO: Share between commands
    /// Obtain package path
    private func path(arguments: ArgumentParser.Result) throws -> AbsolutePath {
        if let path = arguments.get(pathArgument) {
            return AbsolutePath(path, relativeTo: FileHandler.shared.currentPath)
        } else {
            return FileHandler.shared.currentPath
        }
    }
}
