import acho
import Foundation

private enum InputError: Error {
    case failedReading
}

/// Interface for reading and processing user input
public protocol InputReading {
    /// Reads String from given options
    /// - Parameters:
    ///     - options: Available String options
    ///     - question: Formulated question
    /// - Returns: Option chosen by user
    func readString(options: [String], question: String) throws -> String
    /// Reads String from given options
    /// - Parameters:
    ///     - question: Formulated question
    /// - Returns: Option chosen by user of given `EnumType`
    func readEnumInput<EnumType: RawRepresentable & CaseIterable>(question: String) throws -> EnumType where EnumType.RawValue == String
    /// Prompts user to either use `defaultValue` if available or provide answer
    /// - Parameters:
    ///     - text: What we are prompting user to do
    ///     - defaultValue: Provide user with `defaultValue`
    /// - Returns: Either `defaultValue` or user-provided answer
    func prompt(_ text: String, defaultValue: String?) -> String
}

extension InputReading {
    func prompt(_ text: String, defaultValue: String? = nil) -> String {
        return prompt(text, defaultValue: defaultValue)
    }
}

/// Handles taking in and processing user input
public final class InputReader: InputReading {
    private let printer: Printing
    
    public init(printer: Printing = Printer()) {
        self.printer = printer
    }
    
    public func readString(options: [String], question: String) throws -> String {
        let acho = Acho<String>()
        guard let answer = acho.ask(question: question, options: options) else { throw InputError.failedReading }
        return answer
    }

    public func readEnumInput<EnumType: RawRepresentable & CaseIterable>(question: String) throws -> EnumType where EnumType.RawValue == String {
        return try readRawInput(options: EnumType.allCases, question: question)
    }
    
    public func prompt(_ text: String, defaultValue: String? = nil) -> String {
        if let defaultValue = defaultValue {
            printer.print(text + " or press enter to use: \(defaultValue) > ", includeNewline: false)
            let readLineValue = readLine() ?? ""
            return readLineValue.isEmpty ? defaultValue : readLineValue
        } else {
            printer.print(text, includeNewline: false)
            let readLineValue = readLine() ?? ""
            return readLineValue.isEmpty ? prompt("Try again: " + text) : readLineValue
        }
    }
    
    // MARK: - Helpers
    
    private func readRawInput<StringRawRepresentable: RawRepresentable, RawCollection: Collection>(options: RawCollection, question: String) throws -> StringRawRepresentable where StringRawRepresentable.RawValue == String, RawCollection.Element == StringRawRepresentable {
        let acho = Acho<String>()
        guard
            let answer = acho.ask(question: question, options: options.map { $0.rawValue }),
            let representedAnswer = StringRawRepresentable(rawValue: answer)
        else { throw InputError.failedReading }
        return representedAnswer
    }
}
