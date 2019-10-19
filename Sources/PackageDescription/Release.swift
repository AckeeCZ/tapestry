public struct Release: Codable {
    public let actions: [ReleaseAction]
    public let add: SourceFilesList?
    public let commitMessage: String
    public let push: Bool
    
    public init(actions: [ReleaseAction] = [],
                add: SourceFilesList? = nil,
                commitMessage: String,
                push: Bool = false) {
        self.actions = actions
        self.add = add
        self.commitMessage = commitMessage
        self.push = push
    }
}