import Foundation

// MARK: - TapestryConfig

public struct TapestryConfig: Codable {
    public let release: ReleaseAction?

    public init(release: Release? = nil) {
        self.release = release
        dumpIfNeeded(self)
    }
}
