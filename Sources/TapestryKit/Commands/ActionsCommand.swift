import SPMUtility
import Basic
import class TuistCore.Printer
import protocol TuistCore.Command
import Foundation

/// List all available actions
final class ActionsCommand: NSObject, Command {
    static var command: String = "actions"
    static var overview: String = "Show available actions"
    
    required init(parser: ArgumentParser) {
        parser.add(subparser: ActionsCommand.command, overview: ActionsCommand.overview)
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        printActions()
    }
    
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
