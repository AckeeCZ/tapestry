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
    public enum DependenciesManager: Equatable {
        /// Cococapods
        case cocoapods
        /// Carthage
        case carthage
        /// Swift Package Manager
        case spm(Platform)
        
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
    
    /// Platforms that you want to support
    /// Other platform-only support will be added in the future
    public enum Platform: String {
        /// Support for iOS
        /// - Parameters:
        ///     - deviceName: What device you want to test this project with
        case iOS
        /// Support for all platforms
        case all
    }
    
    /// You can choose one of `PredefinedAction`s that tapestry provides for you
    /// You can list all using `tapestry actions` and run individual actions `tapestry action action-name`
    public enum PredefinedAction {
        /// Updates version in `README.md` and `YourLibrary.podspec`
        case docsUpdate
        /// Checks compatibility of your library with given dependencies managers
        case dependenciesCompatibility([DependenciesManager])
        /// Creates new release with changelog on Github
        /// - Parameters:
        ///     - owner: Owner of the repository
        ///     - repository: Name of the repository
        case githubRelease(owner: String, repository: String)
    }
    
    /// Describes what should be run
    ///
    /// - custom: is run from root of your library
    /// - predefined: Runs one of `PredefinedAction`s that is provided by tapestry
    public enum Action {
        /// Is run from root of your library
        case custom(tool: String, arguments: [String])
        /// Runs one of `PredefinedAction`s that is provided by tapestry
        case predefined(PredefinedAction)
    }
    
    /// Release action order.
    public let order: Order
    
    /// Action to run
    public let action: Action
    
    public init(
        order: Order,
        action: Action
    ) {
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
