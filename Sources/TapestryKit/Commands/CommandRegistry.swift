//
//  CommandRegistry.swift
//  
//
//  Created by Marek Fořt on 8/22/19.
//

import SPMUtility
import Foundation
import protocol TuistCore.Command
import protocol TuistCore.RawCommand
import protocol TuistCore.HiddenCommand
import protocol TuistCore.ErrorHandling
import protocol TuistCore.FatalError
import struct TuistCore.UnhandledError
import class TuistCore.ErrorHandler
import class TuistCore.Printer
import Basic
import TapestryGen
import TapestryCore

public final class CommandRegistry {
    // MARK: - Attributes

    let parser: ArgumentParser
    var commands: [Command] = []
    var rawCommands: [RawCommand] = []
    var hiddenCommands: [String: HiddenCommand] = [:]
    private let errorHandler: ErrorHandling
    private let processArguments: () -> [String]
    private let processAllArguments: () -> [String]

    // MARK: - Init

    public convenience init() {
        self.init(errorHandler: ErrorHandler(),
                  processArguments: CommandRegistry.processArguments,
                  processAllArguments: CommandRegistry.processAllArguments)
        register(command: InitCommand.self)
        register(command: ReleaseCommand.self)
        register(command: EditCommand.self)
        register(command: UpCommand.self)
        register(command: RunCommand.self)
        register(command: ActionCommand.self)
        register(command: ActionsCommand.self)
        register(command: UpdateCommand.self)
    }

    init(errorHandler: ErrorHandling,
         processArguments: @escaping () -> [String],
         processAllArguments: @escaping () -> [String]) {
        self.errorHandler = errorHandler
        parser = ArgumentParser(commandName: "tapestry",
                                usage: "<command> <options>",
                                overview: "Generate and maintain your package projects.")
        self.processArguments = processArguments
        self.processAllArguments = processAllArguments
    }

    public static func processArguments() -> [String] {
        return Array(ProcessInfo.processInfo.arguments).filter { $0 != "--current" }
    }

    // MARK: - Internal
    
    static func processAllArguments() -> [String] {
        return Array(ProcessInfo.processInfo.arguments)
    }

    func register(command: Command.Type) {
        commands.append(command.init(parser: parser))
    }

    func register(hiddenCommand command: HiddenCommand.Type) {
        hiddenCommands[command.command] = command.init()
    }

    func register(rawCommand command: RawCommand.Type) {
        rawCommands.append(command.init())
        parser.add(subparser: command.command, overview: command.overview)
    }

    // MARK: - Public

    public func run() {
        do {
            // Run local version
            let tapestriesPath = FileHandler.shared.currentPath.appending(component: "Tapestries")
            let processedArguments = processAllArguments()
            if !processArguments().contains(EditCommand.command),
                !processArguments().contains(UpCommand.command),
                !processedArguments.contains("--current"),
                FileHandler.shared.exists(tapestriesPath) {
                do {
                    try PackageController.shared.run("tapestry", arguments: ["--current"] + processedArguments.dropFirst(), path: FileHandler.shared.currentPath)
                } catch let error as PackageControllerError {
                    switch error {
                    case .buildFailed:
                        throw PackageControllerError.buildFailed("tapestry")
                    default:
                        return
                    }
                } catch {
                    
                }
            }
            // Hidden command
            else if let hiddenCommand = hiddenCommand() {
                try hiddenCommand.run(arguments: argumentsDroppingCommand())

                // Raw command
            } else if let commandName = commandName(),
                let command = rawCommands.first(where: { type(of: $0).command == commandName }) {
                try command.run(arguments: argumentsDroppingCommand())

                // Normal command
            } else {
                let parsedArguments = try parse()
                try process(arguments: parsedArguments)
            }
        } catch let error as FatalError {
            errorHandler.fatal(error: error)
        } catch {
            errorHandler.fatal(error: UnhandledError(error: error))
        }
    }

    // MARK: - Fileprivate

    func argumentsDroppingCommand() -> [String] {
        return Array(processArguments().dropFirst(2))
    }

    /// Returns the command name.
    ///
    /// - Returns: Command name.
    func commandName() -> String? {
        let arguments = processArguments()
        if arguments.count < 2 { return nil }
        return arguments[1]
    }

    private func parse() throws -> ArgumentParser.Result {
        let arguments = Array(processArguments().dropFirst())
        return try parser.parse(arguments)
    }

    private func hiddenCommand() -> HiddenCommand? {
        let arguments = Array(processArguments().dropFirst())
        guard let commandName = arguments.first else { return nil }
        return hiddenCommands[commandName]
    }

    private func process(arguments: ArgumentParser.Result) throws {
        guard let subparser = arguments.subparser(parser) else {
            parser.printUsage(on: stdoutStream)
            return
        }
        if let command = commands.first(where: { type(of: $0).command == subparser }) {
            try command.run(with: arguments)
        }
    }
}

