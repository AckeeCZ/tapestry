/// Used to replace with given arguments
/// eg when you run `tapestry release 0.0.1` Argument.version will be replaced with that version
public enum Argument: String, CustomStringConvertible {
    /// Replaced in `tapestry release 0.0.1`
    case version = "$VERSION"
    
    public var description: String {
        return rawValue
    }
}
