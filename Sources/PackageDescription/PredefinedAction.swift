/// You can choose one of `PredefinedAction`s that tapestry provides for you
/// You can list all using `tapestry actions` and run individual actions `tapestry action action-name`
public enum PredefinedAction: Codable {
    /// Updates version in `README.md` and `YourLibrary.podspec`
    case docsUpdate
    /// Checks compatibility of your library with given dependencies managers
    case dependenciesCompatibility([DependenciesManager])

    private enum Kind: String, Codable {
        case docsUpdate
        case dependenciesCompatibility
    }
    
    enum CodingKeys: String, CodingKey {
        case kind
        case tool
        case arguments
        case dependenciesManagers
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
        }
    }
}
