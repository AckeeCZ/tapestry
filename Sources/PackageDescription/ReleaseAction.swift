/// Describes individual release action
public struct ReleaseAction: Equatable, Codable {    
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
    /// - Parameters:
    ///     - tool: Name of tool you want to run
    ///     - arguments: Arguments to pass to the tool
    public static func pre(tool: String,
                           arguments: [String] = []) -> ReleaseAction {
        return ReleaseAction(order: .pre,
                             action: .custom(tool: tool, arguments: arguments))
    }
    
    /// Creates custom post action
    /// - Parameters:
    ///     - tool: Name of tool you want to run
    ///     - arguments: Arguments to pass to the tool
    public static func post(tool: String,
                            arguments: [String] = []) -> ReleaseAction {
        return ReleaseAction(order: .post,
                            action: .custom(tool: tool, arguments: arguments))
    }
    
    /// Creates predefined pre action
    /// - Parameters:
    ///     - predefinedAction: Specify which `PredefinedAction` to run
    public static func pre(_ predefinedAction: PredefinedAction) -> ReleaseAction {
        return releaseAction(predefinedAction,
                             order: .pre)
    }
    
    /// Creates predefined post action
    /// - Parameters:
    ///     - predefinedAction: Specify which `PredefinedAction` to run
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
