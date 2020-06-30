/// Describes dependencies manager that you can add to your release action
/// You can use this enum for `PredefinedAction.dependenciesCompatibility`
public enum DependenciesManager: Codable, Equatable {
    /// Cococapods
    case cocoapods
    /// Carthage
    case carthage
    /// Swift Package Manager
    case spm(Platform)
    
    private enum Kind: String, Codable {
        case cocoapods
        case carthage
        case spm
    }
    
    enum CodingKeys: String, CodingKey {
        case kind
        case platform
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .cocoapods:
            self = .cocoapods
        case .carthage:
            self = .carthage
        case .spm:
            let platform = try container.decode(Platform.self, forKey: .platform)
            self = .spm(platform)
        }
    }
        
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .cocoapods:
            try container.encode(Kind.cocoapods, forKey: .kind)
        case .carthage:
            try container.encode(Kind.carthage, forKey: .kind)
        case let .spm(platform):
            try container.encode(Kind.spm, forKey: .kind)
            try container.encode(platform, forKey: .platform)
        }
    }
    
    public static func == (lhs: DependenciesManager, rhs: DependenciesManager) -> Bool {
        switch (lhs, rhs) {
        case (.cocoapods, .cocoapods):
            return true
        case (.carthage, .carthage):
            return true
        case let (.spm(lhsPlatform), .spm(rhsPlatform)):
            return lhsPlatform == rhsPlatform
        default:
            return false
        }
    }
}
