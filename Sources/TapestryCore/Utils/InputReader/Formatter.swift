import Foundation

/// Protocol that defines an interface for formatting the prompt output.
protocol Formatting {
    /// Formats the question and the options and returns and array
    /// with the lines that should be printed.
    ///
    /// - Parameters:
    ///   - question: Prompt question.
    ///   - options: List of options with a boolean that indicates if the option is selected.
    /// - Returns: Formatted lines.
    func format(question: String, options: [(String, Bool)]) -> [String]
}

final class Formatter: Formatting {
    /// Formats the question and the options and returns and array
    /// with the lines that should be printed.
    ///
    /// - Parameters:
    ///   - question: Prompt question.
    ///   - options: List of options with a boolean that indicates if the option is selected.
    /// - Returns: Formatted lines.
    func format(question: String, options: [(String, Bool)]) -> [String] {
        var output: [String] = []
        output.append("\(question) \("(Choose with ↑ ↓ ⏎)".yellow())")

        for i in 0 ..< options.count {
            let option = options[i]
            let prefix = option.1 ? "> " : "  "
            let item = "\(prefix)\(i + 1). \(option.0)"
            output.append(option.1 ? item.cyan() : item)
        }

        return output
    }
}
