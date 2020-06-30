import TapestryCore

final class ActionsService {
    func run() throws {
        printActions()
    }
    
    // MARK: - Helpers
    
    private func printActions() {
        Action.allCases.forEach {
            switch $0 {
            case .docsUpdate:
                Printer.shared.print("docs-update\tUpdate docs with a given version")
            case .dependenciesCompatibility:
                Printer.shared.print("compatibility\tCheck compatibility with given dependency managers")
            }
        }
    }
}
