import TSCBasic
import Foundation

/// Protocol that defines an interface to ask the user to choose an option from a given list.
public protocol AchoProtocol {
    associatedtype C

    /// Prints the question and the options in the terminal and subscribes to key events
    /// to move the selection up and down. When the user presses enter, it returns
    /// the selected option.
    ///
    /// - Parameters:
    ///   - question: Question to be asked.
    ///   - options: List of options
    /// - Returns: Selectd option (if any).
    func ask(question: String, options: [C]) -> C?
}

/// Public interface of the library.
public final class Acho<C: CustomStringConvertible & Hashable>: AchoProtocol {
    /// Terminal controller.
    let terminalController: TerminalControlling

    /// Key reader.
    let keyReader: KeyReading

    /// Formatter instance.
    let formatter: Formatting

    /// Public constructor that takes no arguments
    public convenience init() {
        let controller = TerminalController(stream: stdoutStream)!
        self.init(terminalController: controller,
                  keyReader: KeyReader(),
                  formatter: Formatter())
    }

    /// Initialize the class with its attributes
    ///
    /// - Parameters:
    ///   - terminalController: Terminal controller.
    ///   - keyReader: Instance to subscribe to key events.
    init(terminalController: TerminalControlling,
         keyReader: KeyReading,
         formatter: Formatting) {
        self.terminalController = terminalController
        self.keyReader = keyReader
        self.formatter = formatter
    }

    /// Prints the question and the options in the terminal and subscribes to key events
    /// to move the selection up and down. When the user presses enter, it returns
    /// the selected option.
    ///
    /// - Parameters:
    ///   - question: Question to be asked.
    ///   - options: List of options.
    /// - Returns: Selectd option (if any).
    public func ask(question: String, options: [C]) -> C? {
        precondition(options.count > 1, "there should be at least one item")

        let state = State(options: options)

        let output = state.output()
        var printedLines: Int? = print(question, output: output)
        var selectedItem: C?

        keyReader.subscribe { event in
            switch event {
            case .down:
                state.down()
                let output = state.output()
                printedLines = self.print(question, output: output, printedLines: printedLines)
            case .up:
                state.up()
                let output = state.output()
                printedLines = self.print(question, output: output, printedLines: printedLines)
            case .select:
                selectedItem = state.current()
            case .exit:
                break
            }
        }

        if let printedLines = printedLines {
            clear(lines: printedLines)
        }
        return selectedItem
    }

    /// Clears the last n lines from the terminal.
    ///
    /// - Parameter lines: Number of lines to be cleared.
    fileprivate func clear(lines: Int) {
        for _ in 0 ..< lines {
            terminalController.moveCursor(up: 1)
            terminalController.clearLine()
        }
    }

    /// Prints the state output in the terminal.
    ///
    /// - Parameters:
    ///   - question: Question.
    ///   - output: Output options.
    ///   - printedLines: The number of currently printed lines.
    /// - Returns: The number of lines that have been printed.
    fileprivate func print(_ question: String, output: [(C, Bool)], printedLines: Int? = nil) -> Int {
        if let printedLines = printedLines {
            terminalController.moveCursor(up: printedLines)
        }
        let lines = formatter.format(question: question, options: output.map({ ($0.0.description, $0.1) }))
        lines.forEach({
            terminalController.clearLine()
            terminalController.write("\($0)\n")
        })
        return lines.count
    }
}
