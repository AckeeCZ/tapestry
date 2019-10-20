import class TuistCore.Glob

public struct Release {
    public let actions: [ReleaseAction]
    public let add: [String]
    public let commitMessage: String
    public let push: Bool
    
    public init(actions: [ReleaseAction] = [],
                add: [String] = [],
                commitMessage: String,
                push: Bool = false) {
        self.actions = actions
        self.add = add
        self.commitMessage = commitMessage
        self.push = push
    }
}
