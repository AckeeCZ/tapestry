import Basic
import SPMUtility
import class TuistCore.FileHandler

/// Used by `.docsUpdate` `ReleaseAction`
public protocol DocsUpdating {
    /// Update `README.md` and `Library.podspec`
    /// - Parameters:
    ///     - path: Root path of the library
    ///     - version: Version to update the docs to
    func updateDocs(path: AbsolutePath, version: Version) throws
}

public final class DocsUpdater: DocsUpdating {
    public init() { }
    
    public func updateDocs(path: AbsolutePath, version: Version) throws {
        let name = try PackageController.shared.name(from: path)
        
        Printer.shared.print("Updating docs 📚")
        
        try updateVersionInPodspec(path: path,
                           name: name,
                           version: version)
        
        try updateVersionInReadme(path: path,
                                  name: name,
                                  version: version)
        
        try updateVersionInChangelog(path: path,
                                     version: version)
    }
    
    // MARK: - Helpers
    
    private func updateVersionInPodspec(path: AbsolutePath,
                                        name: String,
                                        version: Version) throws {
        let podspecPath = path.appending(component: "\(name).podspec")
        guard FileHandler.shared.exists(podspecPath) else {
            Printer.shared.print(warning: "Podspec at \(podspecPath.pathString) does not exist, skipping...")
            return
        }
        var content = try FileHandler.shared.readTextFile(podspecPath)
        content = content.replacingOccurrences(
            of: #"s\.version([ ]*)=([ ]*)(["|'])([0-9]|[\.])*(["|'])"#,
            with: "s.version$1=$2$3\(version.description)$5",
            options: .regularExpression
        )
        try content.write(to: podspecPath.url, atomically: true, encoding: .utf8)
    }
    
    private func updateVersionInReadme(path: AbsolutePath,
                                       name: String,
                                       version: Version) throws {
        let readmePath = path.appending(component: "README.md")
        guard FileHandler.shared.exists(readmePath) else {
            Printer.shared.print(warning: "Podspec at \(readmePath.pathString) does not exist, skipping...")
            return
        }
        var content = try FileHandler.shared.readTextFile(readmePath)
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
    
    // TODO: Add changelog to generated template
    private func updateVersionInChangelog(path: AbsolutePath,
                                          version: Version) throws {
        let changelogPath = path.appending(component: "CHANGELOG.md")
        guard FileHandler.shared.exists(changelogPath) else {
            Printer.shared.print(warning: "CHANGELOG.md at \(changelogPath.pathString) does not exist, skipping...")
            return
        }
        var content = try FileHandler.shared.readTextFile(changelogPath)
        content = content
        .replacingOccurrences(
            of: "## Next",
            with: """
            ## Next
            
            ## \(version.description)
            """,
            options: .regularExpression
        )
        
        try content.write(to: changelogPath.url, atomically: true, encoding: .utf8)
    }
}