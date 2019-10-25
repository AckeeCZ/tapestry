// MARK: - FileList

/// A model to refer to source files
public final class SourceFileGlob: Equatable, ExpressibleByStringLiteral, Codable {
    /// Relative glob pattern.
    public let glob: String

    /// Initializes a SourceFileGlob instance.
    ///
    /// - Parameters:
    ///   - glob: Relative glob pattern.
    public init(_ glob: String) {
        self.glob = glob
    }

    public convenience init(stringLiteral value: String) {
        self.init(value)
    }
    
    public static func == (lhs: SourceFileGlob, rhs: SourceFileGlob) -> Bool {
        return lhs.glob == rhs.glob
    }
}

/// List of source files, you define individual sources using `SourceFileGlob`
public final class SourceFilesList: Equatable, Codable {
    public enum CodingKeys: String, CodingKey {
        case globs
    }

    /// List glob patterns.
    public let globs: [SourceFileGlob]

    /// Initializes the source files list with the glob patterns.
    ///
    /// - Parameter globs: Glob patterns.
    public init(globs: [SourceFileGlob]) {
        self.globs = globs
    }

    /// Initializes the source files list with the glob patterns as strings.
    ///
    /// - Parameter globs: Glob patterns.
    public init(globs: [String]) {
        self.globs = globs.map(SourceFileGlob.init)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        globs = try container.decode([SourceFileGlob].self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(globs)
    }
    
    public static func == (lhs: SourceFilesList, rhs: SourceFilesList) -> Bool {
        return lhs.globs == rhs.globs
    }
}

/// Support file as single string
extension SourceFilesList: ExpressibleByStringLiteral {
    public convenience init(stringLiteral value: String) {
        self.init(globs: [value])
    }
}

extension SourceFilesList: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: SourceFileGlob...) {
        self.init(globs: elements)
    }
}
