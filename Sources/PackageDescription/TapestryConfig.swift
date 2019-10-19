import Foundation

// MARK: - TapestryConfig

public struct TapestryConfig: Codable {
    public let release: Release?

    public init(release: Release? = nil) {
        self.release = release
        dumpIfNeeded(self)
    }
}
