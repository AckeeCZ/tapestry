import Foundation
import protocol TuistSupport.ErrorHandling
import protocol TuistSupport.FatalError
import struct TuistSupport.UnhandledError
import class TuistSupport.ErrorHandler
import TSCBasic
import TapestryGen
import TapestryCore
import ArgumentParser

public struct TapestryCommand: ParsableCommand {
    public init() {}
    
    public static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "tapestry",
            abstract: "Generate and maintain your swift package projects.",
            subcommands: [
                //                                InitCommand.self
                //                                ReleaseCommand.self
                //                                EditCommand.self
                //                                UpCommand.self
                ActionCommand.self,
                ActionsCommand.self
            ]
        )
    }
    
    public static func main(_ arguments: [String]? = nil) -> Never {
        let errorHandler = ErrorHandler()
        var command: ParsableCommand
        do {
            let processedArguments = Array(processArguments(arguments)?.dropFirst() ?? [])
            command = try parseAsRoot(processedArguments)
        } catch {
            Printer.shared.print(errorMessage: fullMessage(for: error))
            _exit(exitCode(for: error).rawValue)
        }
        do {
            try command.run()
            exit()
        } catch let error as FatalError {
            errorHandler.fatal(error: error)
            _exit(exitCode(for: error).rawValue)
        } catch {
            // Exit cleanly
            if exitCode(for: error).rawValue == 0 {
                exit(withError: error)
            } else {
                errorHandler.fatal(error: UnhandledError(error: error))
                _exit(exitCode(for: error).rawValue)
            }
        }
    }
    
    // MARK: - Helpers
    
    static func processArguments(_ arguments: [String]? = nil) -> [String]? {
        let arguments = arguments ?? Array(ProcessInfo.processInfo.arguments)
        return arguments.filter { $0 != "--verbose" }
    }
}
