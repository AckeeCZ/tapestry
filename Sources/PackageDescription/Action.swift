/// Describes what should be run
///
/// - custom: is run from root of your library
/// - predefined: Runs one of `PredefinedAction`s that is provided by tapestry
public enum Action: Codable {
    case custom(tool: String, arguments: [String])
    case predefined(PredefinedAction)
    
    private enum Kind: String, Codable {
        case custom
        case predefined
    }

    enum CodingKeys: String, CodingKey {
        case kind
        case tool
        case arguments
        case action
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .custom:
            let tool = try container.decode(String.self, forKey: .tool)
            let arguments = try container.decode([String].self, forKey: .arguments)
            self = .custom(tool: tool, arguments: arguments)
        case .predefined:
            let action = try container.decode(PredefinedAction.self, forKey: .action)
            self = .predefined(action)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .custom(tool: tool, arguments: arguments):
            try container.encode(Kind.custom, forKey: .kind)
            try container.encode(tool, forKey: .tool)
            try container.encode(arguments, forKey: .arguments)
        case let .predefined(action):
            try container.encode(Kind.predefined, forKey: .kind)
            try container.encode(action, forKey: .action)
        }
    }
}
