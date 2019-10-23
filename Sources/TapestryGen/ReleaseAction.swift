/// Describes individual release action
public struct ReleaseAction {
    /// Order when the action gets executed.
    ///
    /// - pre: Before commiting and tagging new version.
    /// - post: After commiting and tagging new version.
    public enum Order {
        /// Before commiting and tagging new version.
        case pre
        /// After tcommiting and tagging new version.
        case post
    }
    
    /// Describes dependencies manager that you can add to your release action
    /// You can use this enum for `PredefinedAction.dependenciesCompatibility`
    public enum DependenciesManager: String {
        /// Cococapods
        case cocoapods
        /// Carthage
        case carthage
        /// Swift Package Manager
        case spm
    }
    
    /// You can choose one of `PredefinedAction`s that tapestry provides for you
    /// You can list all using `tapestry actions` and run individual actions `tapestry action action-name`
    public enum PredefinedAction {
        /// Updates version in `README.md` and `YourLibrary.podspec`
        case docsUpdate
        /// Runs `tool` with given `arguments` from `Tapestries/Package.swift`
        case run(tool: String, arguments: [String])
        /// Checks compatibility of your library with given dependencies managers
        case dependenciesCompatibility([DependenciesManager])
    }
    
    /// Describes what should be run
    ///
    /// - custom: is run from root of your library
    /// - predefined: Runs one of `PredefinedAction`s that is provided by tapestry
    public enum Action {
        case custom(tool: String, arguments: [String])
        case predefined(PredefinedAction)
    }
    
    /// Release action order.
    public let order: Order
    
    /// Action to run
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
