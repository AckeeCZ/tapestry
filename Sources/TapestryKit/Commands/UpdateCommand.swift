import Basic
import protocol TuistCore.Command
import protocol TuistCore.FatalError
import enum TuistCore.ErrorType
import Foundation
import TapestryGen
import SPMUtility
import TapestryCore

enum UpdateError: FatalError, Equatable {
    case tapestriesFolderMissing(AbsolutePath)
    
    var description: String {
        switch self {
        case let .tapestriesFolderMissing(path):
            return "Could not find Tapestries folder at \(path.pathString). You should configure it with \"tapestry up\""
        }
    }
    
    var type: ErrorType { .abort }
    
    public static func == (lhs: UpdateError, rhs: UpdateError) -> Bool {
        switch (lhs, rhs) {
            case let (.tapestriesFolderMissing(lhsPath), .tapestriesFolderMissing(rhsPath)):
                return lhsPath == rhsPath
        }
    }
}

/// This command updates local tapestry and develoepr dependencies
final class UpdateCommand: NSObject, Command {
    static var command: String = "update"
    static var overview: String = "Updates local tapestry and dependencies in \"Tapestries/Package.swift\""

    let pathArgument: OptionArgument<String>
    
    required init(parser: ArgumentParser) {
        let subParser = parser.add(subparser: UpdateCommand.command, overview: UpdateCommand.overview)
        
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to your Swift framework",
                                     completion: .filename)
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        let path = try self.path(arguments: arguments).appending(component: Constants.tapestriesName)
        
        guard FileHandler.shared.exists(path) else { throw UpdateError.tapestriesFolderMissing(path) }
        
        try PackageController.shared.update(path: path)
    }
    
    /// Obtain package path
    private func path(arguments: ArgumentParser.Result) throws -> AbsolutePath {
        if let path = arguments.get(pathArgument) {
            return AbsolutePath(path, relativeTo: FileHandler.shared.currentPath)
        } else {
            return FileHandler.shared.currentPath
        }
    }
}
