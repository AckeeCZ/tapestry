import Foundation

extension Data {
    /// Returns the hex representation of the data
    var hexDescription: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
}
