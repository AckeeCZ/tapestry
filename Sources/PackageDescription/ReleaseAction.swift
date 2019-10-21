/// Describes individual release action
public struct ReleaseAction: Equatable, Codable {
    /// Order when the action gets executed.
    ///
    /// - pre: Before commiting and tagging new version.
    /// - post: After tcommiting and tagging new version.
    public enum Order: String, Codable {
        case pre
        case post
    }
    
    /// Describes dependencies manager that you can add to your release action
    /// You can use this enum for `PredefinedAction.dependenciesCompatibility`
    public enum DependendenciesManager: String, Codable {
        /// Cococapods
        case cocoapods
        /// Carthage
        case carthage
        /// Swift Package Manager
        case spm
    }
    
    /// You can choose one of `PredefinedAction`s that tapestry provides for you
    /// You can list all using `tapestry actions` and run individual actions `tapestry action action-name`
    public enum PredefinedAction: Codable {
        /// Updates version in `README.md` and `YourLibrary.podspec`
        case docsUpdate
        /// Runs `tool` with given `arguments` from `Tapestries/Package.swift`
        case run(tool: String, arguments: [String])
        /// Checks compatibility of your library with given dependencies managers
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
    
    /// Release action order
    public let order: Order
    
    /// Action to run
    public let action: Action
    
    init(order: Order,
         action: Action) {
        self.order = order
        self.action = action
    }
    
    /// Creates custom pre action
    public static func pre(tool: String,
                           arguments: [String] = []) -> ReleaseAction {
        return ReleaseAction(order: .pre,
                             action: .custom(tool: tool, arguments: arguments))
    }
    
    /// Creates custom post action
    public static func post(tool: String,
                            arguments: [String] = []) -> ReleaseAction {
        return ReleaseAction(order: .post,
                            action: .custom(tool: tool, arguments: arguments))
    }
    
    /// Creates predefined pre action
    public static func pre(_ predefinedAction: PredefinedAction) -> ReleaseAction {
        return releaseAction(predefinedAction,
                             order: .pre)
    }
    
    /// Creates predefined post action
    public static func post(_ predefinedAction: PredefinedAction) -> ReleaseAction {
        return releaseAction(predefinedAction,
                             order: .post)
    }
    
    static func releaseAction(_ predefinedAction: PredefinedAction, order: Order) -> ReleaseAction {
        ReleaseAction(order: order, action: .predefined(predefinedAction))
    }
    
    public static func == (lhs: ReleaseAction, rhs: ReleaseAction) -> Bool {
        guard lhs.order == rhs.order else { return false }
        switch (lhs.action, rhs.action) {
            case let (.custom(tool: lhsTool, arguments: lhsArguments), .custom(tool: rhsTool, arguments: rhsArguments)):
            return lhsTool == rhsTool && lhsArguments == rhsArguments
        case let (.predefined(lhsAction), .predefined(rhsAction)):
            switch (lhsAction, rhsAction) {
            case (.docsUpdate, .docsUpdate):
                return true
            case let (.dependenciesCompatibility(lhsManagers), .dependenciesCompatibility(rhsManagers)):
                return lhsManagers == rhsManagers
            case let (.run(tool: lhsTool, arguments: lhsArguments), .run(tool: rhsTool, arguments: rhsArguments)):
                return lhsTool == rhsTool && lhsArguments == rhsArguments
            default:
                return false
            }
        default:
            return false
        }
    }
}
