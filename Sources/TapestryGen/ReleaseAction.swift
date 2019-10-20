public struct ReleaseAction {
    /// Order when the action gets executed.
    ///
    /// - pre: Before the sources and resources build phase.
    /// - post: After the sources and resources build phase.
    public enum Order {
        case pre
        case post
    }
    
    public enum PredefinedAction {
        case docsUpdate
        /// Check dependencies
//        case dependenciesCompatibility
    }
    
    /// Release action order.
    public let order: Order
    
    /// Name of the tool to execute. Tapestry will look up the tool in `Tapestries`, otherwise run the locally installed version of the tool.
    public let tool: String
    
    /// Arguments that to be passed.
    public let arguments: [String]
    
    public init(order: Order,
                tool: String,
                arguments: [String]) {
        self.order = order
        self.tool = tool
        self.arguments = arguments
    }
}

extension ReleaseAction {
    public var isPre: Bool {
        switch self.order {
        case .pre:
            return true
        case .post:
            return false
        }
    }
    
    public var isPost: Bool {
        switch self.order {
        case .pre:
            return false
        case .post:
            return true
        }
    }
}
