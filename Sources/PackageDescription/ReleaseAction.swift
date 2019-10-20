public struct ReleaseAction: Codable {
    /// Order when the action gets executed.
    ///
    /// - pre: Before the sources and resources build phase.
    /// - post: After the sources and resources build phase.
    public enum Order: String, Codable {
        case pre
        case post
    }
    
    public enum PredefinedAction {
        case docsUpdate
        /// Check dependencies
//        case dependenciesCompatibility
    }
    
    public enum Argument: String {
        case version = "$VERSION"
    }
    
    /// Release action order.
    public let order: Order
    
    /// Name of the tool to execute. Tapestry will look up the tool in `Tapestries`, otherwise run the locally installed version of the tool.
    public let tool: String
    
    /// Arguments that to be passed.
    public let arguments: [String]
    
    init(order: Order,
         tool: String,
         arguments: [String]) {
        self.order = order
        self.tool = tool
        self.arguments = arguments
    }
    
    public static func pre(tool: String,
                           arguments: [String] = []) -> ReleaseAction {
        return ReleaseAction(order: .pre,
                             tool: tool,
                             arguments: arguments)
    }
    
    public static func post(tool: String,
                            arguments: [String] = []) -> ReleaseAction {
        return ReleaseAction(order: .post,
                             tool: tool,
                             arguments: arguments)
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
        switch predefinedAction {
        case .docsUpdate:
            return ReleaseAction(order: order,
                                 tool: "tapestry",
                                 arguments: ["action", "docs-update", Argument.version.rawValue])
        }
    }
}
