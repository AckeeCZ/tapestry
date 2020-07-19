import Foundation
import OctoKit
import TSCUtility
import protocol TuistSupport.FatalError
import enum TuistSupport.ErrorType

enum GithubControllerError: FatalError {
    case invalidURL(Foundation.URL)
    
    var type: ErrorType {
        switch self {
        case .invalidURL:
            return .bug
        }
    }
    
    var description: String {
        switch self {
        case let .invalidURL(url):
            return "\(url.absoluteString) is invalid."
        }
    }
}

protocol GithubControlling {
    func release(
        owner: String,
        repository: String,
        version: Version,
        changelogDescription: String
    ) throws -> Foundation.URL
    
    func uploadAsset(
        url: Foundation.URL,
        assetData: Data,
        name: String
    ) throws
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
                    result = .success(release.assetsURL)
                case let .failure(error):
                    result = .failure(error)
                }
                group.leave()
            }
        )
        
        group.wait()
        return try result.get()
    }
    
    func uploadAsset(
        url: Foundation.URL,
        assetData: Data,
        name: String
    ) throws {
        Printer.shared.print("Uploading \(name) asset 📦")
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { throw GithubControllerError.invalidURL(url) }
        components.host = "uploads.github.com"
        components.queryItems = [
            URLQueryItem(name: "name", value: name)
        ]

        guard let uploadURL = components.url else { fatalError() }
        
        let group = DispatchGroup()
        group.enter()
        
        var result: Result<Void, Error>!
        
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.setValue("application/zip", forHTTPHeaderField: "Content-Type")
        
        let task = try authenticate().uploadTask(with: request, from: assetData) { data, response, error in
            if let response = response as? HTTPURLResponse {
                if !(200..<300).contains(response.statusCode) {
                    var userInfo = [String: Any]()
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        userInfo["TapestryErrorKey"] = json as Any?
                    }
                    let error = NSError(domain: "tapestry.domain", code: response.statusCode, userInfo: userInfo)
                    result = .failure(error)
                    group.leave()
                    return
                }
            }

            if let error = error {
                result = .failure(error)
            } else {
                result = .success(())
            }
            
            group.leave()
        }
        task.resume()

        group.wait()
        return try result.get()
    }
    
    // MARK: - Helpers
    
    /// Sets up the URLSession to be authenticated for the GitHub API.
    private func authenticate() throws -> URLSession {
        let token = try Token(environment: ProcessInfo.processInfo.environment)
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(token.base64Encoded)"]
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }
}
