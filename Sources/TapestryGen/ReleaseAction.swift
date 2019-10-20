public struct ReleaseAction {
    /// Order when the action gets executed.
    ///
    /// - pre: Before the sources and resources build phase.
    /// - post: After the sources and resources build phase.
    public enum Order {
        case pre
        case post
    }
    
    public enum DependenciesManager: String {
        case cocoapods
        case carthage
        case spm
    }
    
    public enum PredefinedAction {
        case docsUpdate
        case run(tool: String, arguments: [String])
        case dependenciesCompatibility([DependenciesManager])
    }
    
    public enum Action {
        case custom(tool: String, arguments: [String])
        case predefined(PredefinedAction)
    }
    
    /// Release action order.
    public let order: Order
    
    public let action: Action
    
    public init(order: Order,
                action: Action) {
        self.order = order
        self.action = action
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
