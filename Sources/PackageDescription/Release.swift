/// Describes Release process
public struct Release: Equatable, Codable {
    /// Release actions to be run pre or post committing and pushing new release
    public let actions: [ReleaseAction]
    /// After running `.pre` `ReleaseAction`s, tapestry will do `git add` for given source files
    public let add: SourceFilesList?
    /// Commit message for the new release. Use `Argument.version` to add the release version number to the commit message
    public let commitMessage: String
    /// Set to `true` if you want to push the new changes
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
