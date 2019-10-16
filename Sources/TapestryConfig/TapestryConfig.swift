// MARK: - TapestryConfig

public struct TapestryConfig: Codable {
    public let release: ReleaseAction?

    public init(release: ReleaseAction? = nil) {
        self.release = release
    }
}

public struct ReleaseAction: Codable {
    public let add: SourceFilesList?
    public let commitMessage: String?
    public let push: Bool
    
    public init(add: SourceFilesList? = nil,
                commitMessage: String? = nil,
                push: Bool = false) {
        self.add = add
        self.commitMessage = commitMessage
        self.push = push
    }
}
