/// You can choose one of `PredefinedAction`s that tapestry provides for you
/// You can list all using `tapestry actions` and run individual actions `tapestry action action-name`
public enum PredefinedAction: Codable {
    /// Updates version in `README.md` and `YourLibrary.podspec`
    case docsUpdate
    /// Checks compatibility of your library with given dependencies managers
    case dependenciesCompatibility([DependenciesManager])
    /// Creates new release with changelog on Github
    /// Example: fortmarek/tapestry where fortmarek is owner and tapestry is name of the repository
    /// - Parameters:
    ///     - owner: Owner of the repository
    ///     - repository: Name of the repository
    ///     - assetPaths: Relative paths to the root of the project that will be uploaded alongside the release
    case githubRelease(owner: String, repository: String, assetPaths: [String])
    
    /// Creates new release with changelog on Github
    /// Example: fortmarek/tapestry where fortmarek is owner and tapestry is name of the repository
    /// - Parameters:
    ///     - owner: Owner of the repository
    ///     - repository: Name of the repository
    public static func githubRelease(owner: String, repository: String) -> PredefinedAction {
        .githubRelease(owner: owner, repository: repository, assetPaths: [])
    }

    private enum Kind: String, Codable {
        case docsUpdate
        case dependenciesCompatibility
        case githubRelease
    }
    
    enum CodingKeys: String, CodingKey {
        case kind
        case tool
        case arguments
        case dependenciesManagers
        case githubOwner
        case githubRepository
        case githubAssetPaths
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .docsUpdate:
            self = .docsUpdate
        case .dependenciesCompatibility:
            let dependenciesManagers = try container.decode([DependenciesManager].self, forKey: .dependenciesManagers)
            self = .dependenciesCompatibility(dependenciesManagers)
        case .githubRelease:
            let githubOwner = try container.decode(String.self, forKey: .githubOwner)
            let githubRepository = try container.decode(String.self, forKey: .githubRepository)
            let assetPaths = try container.decode([String].self, forKey: .githubAssetPaths)
            self = .githubRelease(owner: githubOwner, repository: githubRepository, assetPaths: assetPaths)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .docsUpdate:
            try container.encode(Kind.docsUpdate, forKey: .kind)
        case let .dependenciesCompatibility(dependenciesManagers):
            try container.encode(Kind.dependenciesCompatibility, forKey: .kind)
            try container.encode(dependenciesManagers, forKey: .dependenciesManagers)
        case let .githubRelease(owner: owner, repository: repository, assetPaths: assetPaths):
            try container.encode(Kind.githubRelease, forKey: .kind)
            try container.encode(owner, forKey: .githubOwner)
            try container.encode(repository, forKey: .githubRepository)
            try container.encode(assetPaths, forKey: .githubAssetPaths)
        }
    }
}
