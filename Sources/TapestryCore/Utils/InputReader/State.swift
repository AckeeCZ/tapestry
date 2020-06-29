import Foundation

/// It represents the state of the prompt.
class State<C> {
    /// Amount of elements shown
    let span: Int = 5

    /// List of options the user can select from.
    private let options: [C]

    /// Current index.
    private(set) var currentIndex: Int

    /// Initializes the state.
    ///
    /// - Parameters:
    ///   - options: List of options the user can select from.
    init(options: [C]) {
        self.options = options
        currentIndex = 0
    }

    /// Gets the currently selected option.
    ///
    /// - Returns: The option at the current index.
    func current() -> C {
        return options[self.currentIndex]
    }

    /// Move the selected line one line up.
    ///
    /// - Returns: The output lines.
    func up() {
        currentIndex = (currentIndex - 1 >= 0) ? currentIndex - 1 : options.count - 1
    }

    /// Move the selected line one line down.
    ///
    /// - Returns: The output lines.
    func down() {
        currentIndex = (currentIndex + 1 < options.count) ? currentIndex + 1 : 0
    }

    /// Returns the terminal output for the given state.
    ///
    /// - Returns: Output lines.
    func output() -> [(C, Bool)] {
        var output: [(C, Bool)] = []
        for i in visibleRange() {
            output.append((options[i], i == currentIndex))
        }
        return output
    }

    /// Returns the range of items that should be output.
    ///
    /// - Returns: Range of items that should be visible.
    fileprivate func visibleRange() -> ClosedRange<Int> {
        var lowerIndex = 0
        if currentIndex + span - 1 < options.count {
            lowerIndex = currentIndex
        } else if options.count - span >= 0 {
            lowerIndex = options.count - span
        } else {
            lowerIndex = 0
        }

        let upperIndex = (currentIndex + span - 1 < options.count) ? currentIndex + span - 1 : options.count - 1
        return lowerIndex ... upperIndex
    }
}
