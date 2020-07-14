import Foundation
import TSCUtility
import TSCBasic

public protocol ReleaseControlling {
    func release(
        _ version: Version,
        path: AbsolutePath,
        owner: String,
        repository: String,
        assetPaths: [RelativePath]
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
        repository: String,
        assetPaths: [RelativePath]
    ) throws {
        let changelogDescription = try changelogGenerator.generateChangelog(
            for: version,
            path: path
        )
        
        Printer.shared.print("Creating new Github release ✨")
        
        let uploadAssetURL = try githubController.release(
            owner: owner,
            repository: repository,
            version: version,
            changelogDescription: changelogDescription
        )
        
        try assetPaths
            .map { (AbsolutePath(path, $0), $0.basename) }
            .map { (try FileHandler.shared.readFile($0.0), $0.1) }
            .forEach { assetData, name in
                try githubController.uploadAsset(
                    url: uploadAssetURL,
                    assetData: assetData,
                    name: name
                )
            }
    }
}
