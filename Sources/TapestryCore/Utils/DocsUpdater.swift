import TSCBasic
import TSCUtility
import class TuistSupport.FileHandler

/// Used by `.docsUpdate` `ReleaseAction`
public protocol DocsUpdating {
    /// Update `README.md` and `Library.podspec`
    /// - Parameters:
    ///     - path: Root path of the library
    ///     - version: Version to update the docs to
    func updateDocs(path: AbsolutePath, version: Version) throws
}

/// Used by `.docsUpdate` `ReleaseAction`
public final class DocsUpdater: DocsUpdating {
    public init() { }
    
    public func updateDocs(path: AbsolutePath, version: Version) throws {
        let name = try PackageController.shared.name(from: path)
        
        Printer.shared.print("Updating docs 📚")
        
        let lastVersion = try? GitController.shared.allTags(path: path).sorted(by: >).first
        
        try updateVersionInPodspec(path: path,
                           name: name,
                           version: version)
        
        try updateVersionInReadme(path: path,
                                  name: name,
                                  version: version,
                                  lastVersion: lastVersion)
        
        try updateVersionInChangelog(path: path,
                                     version: version)
    }
    
    // MARK: - Helpers
    
    /// Updates version in `.podspec`
    /// - Parameters:
    ///     - path: Framework's root path
    ///     - name: Name of framework
    ///     - version: Provided version to update
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
    
    /// Updates version in `README.md`
    /// - Parameters:
    ///     - path: Framework's root path
    ///     - name: Name of framework
    ///     - version: Provided version to update
    ///     - lastVersion: Uses last version from git and replaces it with new version
    private func updateVersionInReadme(path: AbsolutePath,
                                       name: String,
                                       version: Version,
                                       lastVersion: Version?) throws {
        let readmePath = path.appending(component: "README.md")
        guard FileHandler.shared.exists(readmePath) else {
            Printer.shared.print(warning: "Podspec at \(readmePath.pathString) does not exist, skipping...")
            return
        }
        var content = try FileHandler.shared.readTextFile(readmePath)
        // Replacing pods version
        content = content
        .replacingOccurrences(
            // Finds eg: pod "Framework", "~> 6.2.4"
            of: "pod ([\"|'])\(name)([\"|'])" + #", (["|'])~>[ ]?([0-9]|[\.])*(["|'])"#,
            with: "pod $1\(name)$2, $3~> \(version.description)$5",
            options: .regularExpression
        )
        // Replacing SPM version
        .replacingOccurrences(
            // Finds eg: framework.git", .upToNextMajor(from: "0.40.13")),
            of: "\(name)" + #"\.git", \.upToNextMajor\(from:[ ]?"([0-9]|[\.])*""#,
            with: "\(name).git\", .upToNextMajor(from: \"\(version.description)\"",
            options: .regularExpression
        )

        if let lastVersion = lastVersion {
            content = content.replacingOccurrences(
                of: lastVersion.description,
                with: version.description
            )
        }
        
        try content.write(to: readmePath.url, atomically: true, encoding: .utf8)
    }
    
    // TODO: Add changelog to generated template
    /// Updates version in `CHANGELOG.md`
    /// - Parameters:
    ///     - path: Framework's root path
    ///     - version: Provided version to update
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
