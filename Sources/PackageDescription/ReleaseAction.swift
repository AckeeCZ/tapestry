public struct ReleaseAction: Codable {
    /// Order when the action gets executed.
    ///
    /// - pre: Before the sources and resources build phase.
    /// - post: After the sources and resources build phase.
    public enum Order: String, Codable {
        case pre
        case post
    }
    
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
    
    public enum DependendenciesManager: String, Codable {
        case cocoapods
        case carthage
        case spm
    }
    
    public enum PredefinedAction: Codable {
        case docsUpdate
        case run(tool: String, arguments: [String])
        case dependenciesCompatibility([DependendenciesManager])
    
        private enum Kind: String, Codable {
            case docsUpdate
            case run
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
            case .run:
                let tool = try container.decode(String.self, forKey: .tool)
                let arguments = try container.decode([String].self, forKey: .arguments)
                self = .run(tool: tool, arguments: arguments)
            case .dependenciesCompatibility:
                let dependenciesManagers = try container.decode([DependendenciesManager].self, forKey: .dependenciesManagers)
                self = .dependenciesCompatibility(dependenciesManagers)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .docsUpdate:
                try container.encode(Kind.docsUpdate, forKey: .kind)
            case let .run(tool: tool, arguments: arguments):
                try container.encode(Kind.run, forKey: .kind)
                try container.encode(tool, forKey: .tool)
                try container.encode(arguments, forKey: .arguments)
            case let .dependenciesCompatibility(dependenciesManagers):
                try container.encode(Kind.dependenciesCompatibility, forKey: .kind)
                try container.encode(dependenciesManagers, forKey: .dependenciesManagers)
            }
        }

    }
    
    /// Release action order
    public let order: Order
    
    public let action: Action
    
    init(order: Order,
         action: Action) {
        self.order = order
        self.action = action
    }
    
    public static func pre(tool: String,
                           arguments: [String] = []) -> ReleaseAction {
        return ReleaseAction(order: .pre,
                             action: .custom(tool: tool, arguments: arguments))
    }
    
    public static func post(tool: String,
                            arguments: [String] = []) -> ReleaseAction {
        return ReleaseAction(order: .post,
                            action: .custom(tool: tool, arguments: arguments))
    }
    
    public static func pre(_ predefinedAction: PredefinedAction) -> ReleaseAction {
        return releaseAction(predefinedAction,
                             order: .pre)
    }
    
    public static func post(_ predefinedAction: PredefinedAction) -> ReleaseAction {
        return releaseAction(predefinedAction,
                             order: .post)
    }
    
    static func releaseAction(_ predefinedAction: PredefinedAction, order: Order) -> ReleaseAction {
        ReleaseAction(order: order, action: .predefined(predefinedAction))
    }
}
