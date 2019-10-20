public enum Argument: String, CustomStringConvertible {
    case version = "$VERSION"
    
    public var description: String {
        return rawValue
    }
}
