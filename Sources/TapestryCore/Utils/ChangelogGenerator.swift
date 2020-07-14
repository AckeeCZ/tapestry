import Foundation
import TSCUtility
import TSCBasic
import protocol TuistSupport.FatalError
import enum TuistSupport.ErrorType

enum ChangelogGeneratorError: FatalError, Equatable {
    case newVersionNotFound(Version)
    
    var type: ErrorType {
        switch self {
        case .newVersionNotFound:
            return .abort
        }
    }
    
    var description: String {
        switch self {
        case let .newVersionNotFound(version):
            return "Version \(version.description) was not found in 'CHANGELOG.md'. Make sure to add it before generating changelog. You can also add .docsUpdate action which does that for you"
        }
    }
}

public protocol ChangelogGenerating {
    func generateChangelog(
        for version: Version,
        path: AbsolutePath
    ) throws -> String
}

public final class ChangelogGenerator: ChangelogGenerating {
    public func generateChangelog(
        for version: Version,
        path: AbsolutePath
    ) throws -> String {
        let changelogPath = path.appending(component: "CHANGELOG.md")
        let changelogLines = try FileHandler.shared.readTextFile(changelogPath)
            .components(separatedBy: .newlines)
        
        guard
            let newVersionLine = changelogLines.firstIndex(where: { $0.contains(version.description) })
            else { throw ChangelogGeneratorError.newVersionNotFound(version) }
        let regex = try NSRegularExpression(pattern: "[0-9].[0-9].[0-9]")
        let oldVersionLine = changelogLines
            .suffix(from: newVersionLine + 1)
            .firstIndex(where: {
                regex.firstMatch(
                    in: $0,
                    options: [],
                    range: NSRange(location: 0, length: $0.utf16.count)
                    ) != nil
            }
        )
        let currentChangelogLines = changelogLines[newVersionLine..<(oldVersionLine ?? changelogLines.endIndex)]
        
        return currentChangelogLines.joined(separator: "\n").trimmingCharacters(in: .newlines)
    }
}
