import Foundation
import TuistCore
import TapestryCore
import Basic
import SPMUtility

enum ReleaseError: FatalError, Equatable {
    case noVersion, ungettableProjectName(AbsolutePath)

    var type: ErrorType {
        return .abort
    }

    var description: String {
        switch self {
        case .noVersion:
            return "No version provided."
        case let .ungettableProjectName(path):
            return "Couldn't infer the project name from path \(path.pathString)."
        }
    }
    
    static func == (lhs: ReleaseError, rhs: ReleaseError) -> Bool {
        switch (lhs, rhs) {
        case let (.ungettableProjectName(lhsPath), .ungettableProjectName(rhsPath)):
            return lhsPath == rhsPath
        case (.noVersion, .noVersion):
            return true
        default:
            return false
        }
    }
}

/// This command initializes Swift package with example in current empty directory
final class ReleaseCommand: NSObject, Command {
    static var command: String = "release"
    static var overview: String = "Tags a new release and updates documentation and Pod accordingly"

    let versionArgument: PositionalArgument<Version>
    let pathArgument: OptionArgument<String>

    private let fileHandler: TapestryCore.FileHandling
    private let printer: TapestryCore.Printing
    private let gitController: GitControlling

    required convenience init(parser: ArgumentParser) {
        self.init(parser: parser,
                  fileHandler: FileHandler(),
                  printer: Printer(),
                  gitController: GitController())
    }

    init(parser: ArgumentParser,
         fileHandler: TapestryCore.FileHandling,
         printer: TapestryCore.Printing,
         gitController: GitControlling) {
        let subParser = parser.add(subparser: ReleaseCommand.command, overview: ReleaseCommand.overview)
        versionArgument = subParser.add(positional: "Version", kind: Version.self)
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to the folder where the project will be generated (Default: Current directory).",
                                     completion: .filename)

        self.fileHandler = fileHandler
        self.printer = printer
        self.gitController = gitController
    }

    func run(with arguments: ArgumentParser.Result) throws {
        guard let version = arguments.get(versionArgument) else { throw ReleaseError.noVersion }
        
        printer.print("Updating version 🚀")
        
        let path = try self.path(arguments: arguments)
        let name = try self.name(path: path)
        
        try updateVersionInPodspec(path: path,
                                   name: name,
                                   version: version)
        
        try updateVersionInReadme(path: path,
                                  name: name,
                                  version: version)
        
        try gitController.commit("Version \(version.description)", path: path)
        
        try gitController.tagVersion(version,
                                     path: path)
        
        printer.print(success: "Version updated to \(version.description) 🎉")
    }
    
    // MARK: - Helpers
    
    /// Obtain package path
    private func path(arguments: ArgumentParser.Result) throws -> AbsolutePath {
        if let path = arguments.get(pathArgument) {
            return AbsolutePath(path, relativeTo: fileHandler.currentPath)
        } else {
            return fileHandler.currentPath
        }
    }
    
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
    
    private func updateVersionInPodspec(path: AbsolutePath,
                                        name: String,
                                        version: Version) throws {
        let podspecPath = path.appending(component: "\(name).podspec")
        guard fileHandler.exists(podspecPath) else {
            printer.print(warning: "Podspec at \(podspecPath.pathString) does not exist, skipping...")
            return
        }
        var content = try fileHandler.readTextFile(podspecPath)
        content = content.replacingOccurrences(
            of: #"s\.version = \"(([0-9]|[\.])*)\""#,
            with: "s.version = \"\(version.description)\"",
            options: .regularExpression
        )
        try content.write(to: podspecPath.url, atomically: true, encoding: .utf8)
    }
    
    private func updateVersionInReadme(path: AbsolutePath,
                                       name: String,
                                       version: Version) throws {
        let readmePath = path.appending(component: "README.md")
        guard fileHandler.exists(readmePath) else {
            printer.print(warning: "Podspec at \(readmePath.pathString) does not exist, skipping...")
            return
        }
        var content = try fileHandler.readTextFile(readmePath)
        // Replacing pods version
        content = content
        .replacingOccurrences(
            of: "pod \"\(name)\"" + #", "~>[ ]?([0-9]|[\.])*""#,
            with: "pod \"\(name)\", \"~> \(version.description)\"",
            options: .regularExpression
        )
        // Replacing SPM version
        .replacingOccurrences(
            of: "\(name)" + #"\.git", \.upToNextMajor\(from:[ ]?"([0-9]|[\.])*""#,
            with: "\(name).git\", .upToNextMajor(from: \"\(version.description)\"",
            options: .regularExpression
        )

        try content.write(to: readmePath.url, atomically: true, encoding: .utf8)
    }
}
