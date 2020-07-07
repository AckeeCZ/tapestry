import Foundation
import TSCUtility
import TSCBasic

public protocol ReleaseControlling {
    func release(
        _ version: Version,
        path: AbsolutePath,
        owner: String,
        repository: String
    ) throws
}

public final class ReleaseController: ReleaseControlling {
    private let changelogGenerator: ChangelogGenerating
    private let githubController: GithubControlling
    
    public convenience init() {
        self.init(
            changelogGenerator: ChangelogGenerator(),
            githubController: GithubController()
        )
    }
    
    init(
        changelogGenerator: ChangelogGenerating,
        githubController: GithubControlling
    ) {
        self.changelogGenerator = changelogGenerator
        self.githubController = githubController
    }
    
    public func release(
        _ version: Version,
        path: AbsolutePath,
        owner: String,
        repository: String
    ) throws {
        let changelogDescription = try changelogGenerator.generateChangelog(
            for: version,
            path: path
        )
        _ = try githubController.release(
            owner: owner,
            repository: repository,
            version: version,
            changelogDescription: changelogDescription
        )
        
        Printer.shared.print("Creating new Github release ✨")
    }
}
