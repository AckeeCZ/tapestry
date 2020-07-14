import Foundation
import protocol TuistSupport.FatalError
import enum TuistSupport.ErrorType

struct Token: CustomStringConvertible {
    enum Error: FatalError {
        case missingAccessToken
        case invalidAccessToken
        
        var type: ErrorType {
            switch self {
            case .missingAccessToken,
                 .invalidAccessToken:
                return .abort
            }
        }
        
        var description: String {
            switch self {
            case .missingAccessToken:
                return "GitHub Access Token is missing. Add an environment variable: TAPESTRY_ACCESS_TOKEN='username:access_token'"
            case .invalidAccessToken:
                return "Access token is found but invalid. Correct format: <username>:<access_token>"
            }
        }
    }

    let username: String
    let accessToken: String

    var base64Encoded: String {
        "\(accessToken)".data(using: .utf8)!.base64EncodedString()
    }

    var description: String {
        "\(username):\(accessToken.prefix(5))..."
    }

    init(environment: [String: String]) throws {
        guard let githubAccessToken = environment["TAPESTRY_ACCESS_TOKEN"] else {
            throw Error.missingAccessToken
        }
        let tokenParts = githubAccessToken.split(separator: ":")
        guard tokenParts.count == 2, let username = tokenParts.first, let accessToken = tokenParts.last else {
            throw Error.invalidAccessToken
        }

        self.username = String(username)
        self.accessToken = String(accessToken)
    }
}
