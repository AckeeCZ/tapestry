/// Order when the action gets executed.
///
/// - pre: Before commiting and tagging new version.
/// - post: After commiting and tagging new version.
public enum Order: String, Codable {
    /// Before commiting and tagging new version.
    case pre
    /// After commiting and tagging new version.
    case post
}
