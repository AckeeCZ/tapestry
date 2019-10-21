import Basic

/// Describes Tapestry configuration
public struct TapestryConfig {
    /// Define your release steps
    public let release: Release
    
    public init(release: Release) {
        self.release = release
    }
}
