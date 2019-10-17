import Basic

public final class TapestryConfig {
    public let releaseAction: ReleaseAction
    
    public init(releaseAction: ReleaseAction) {
        self.releaseAction = releaseAction
    }
}

public final class ReleaseAction {
    public let add: [RelativePath]
    public let commitMessage: String?
    public let push: Bool
    
    public init(add: [RelativePath] = [],
                commitMessage: String? = nil,
                push: Bool = false) {
        self.add = add
        self.commitMessage = commitMessage
        self.push = push
    }
}
