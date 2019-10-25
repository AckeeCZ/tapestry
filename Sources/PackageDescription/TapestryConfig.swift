import Foundation

// MARK: - TapestryConfig

/// Describes Tapestry configuration
public struct TapestryConfig: Codable {
    /// Define your release steps
    public let release: Release?

    public init(release: Release? = nil) {
        self.release = release
        dumpIfNeeded(self)
    }
}
