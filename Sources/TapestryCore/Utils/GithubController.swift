import Foundation
import OctoKit
import TSCUtility

protocol GithubControlling {
    func release(
        owner: String,
        repository: String,
        version: Version,
        changelogDescription: String
    ) throws -> Foundation.URL
}

final class GithubController: GithubControlling {
    private let octoKit: Octokit
    
    init(
        octoKit: Octokit = Octokit()
    ) {
        self.octoKit = octoKit
    }
    
    func release(
        owner: String,
        repository: String,
        version: Version,
        changelogDescription: String
    ) throws -> Foundation.URL {
        let group = DispatchGroup()
        group.enter()
        
        var result: Result<Foundation.URL, Error>!
        octoKit.postRelease(
            try authenticate(),
            owner: owner,
            repository: repository,
            tagName: version.description,
            name: version.description,
            body: changelogDescription,
            completion: { releaseResult in
                switch releaseResult {
                case let .success(release):
                    result = .success(release.url)
                case let .failure(error):
                    result = .failure(error)
                }
                group.leave()
            }
        )
        
        group.wait()
        return try result.get()
    }
    
    // MARK: - Helpers
    
    /// Sets up the URLSession to be authenticated for the GitHub API.
    private func authenticate() throws -> URLSession {
        let token = try Token(environment: ProcessInfo.processInfo.environment)
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization": "Basic \(token.base64Encoded)"]
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }
}
