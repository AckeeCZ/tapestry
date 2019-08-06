//
//  GenerateCommand.swift
//  
//
//  Created by Marek Fořt on 8/5/19.
//

import Foundation
import SwiftCLI
import PathKit
import TuistGenerator
import SPMUtility
import Basic

class TapestryModelLoader: GeneratorModelLoading {
    func loadProject(at path: AbsolutePath) throws -> Project {
        return Project(path: path, name: "Puff", settings: .default, filesGroup: .group(name: "mello"), targets: [], schemes: [])
    }

    func loadWorkspace(at path: AbsolutePath) throws -> Workspace {
        return Workspace(name: "hello", projects: [])
    }

    func loadTuistConfig(at path: AbsolutePath) throws -> TuistConfig {
        return TuistConfig(generationOptions: [])
    }
}

open class GenerateCommand: SwiftCLI.Command {

    public let name = "generate"
    public let shortDescription = "Generates Swift code for contract"

    public init() {

    }

    public func execute() throws {
        _ = listOptions(["CLI Tool", "Framework"], prompt: "What type of project do you want to create?")

        let generator = Generator(modelLoader: TapestryModelLoader())
        try generator.generateProject(at: AbsolutePath("/Users/marekfort/Development/ackee/TapestryTests"))
    }

    /**
     List options and prompt the user which one he/she wants to use
     - Parameters:
        - options: List of options to present to user
        - prompt: Description of the presented question/options
    */
    private func listOptions(_ options: [String], prompt: String) -> Int {
        // Prints targets as a list so user can choose with which one they want to bind their files
//        options.enumerated().forEach { index, option in
//            print("\(index + 1). " + option)
//        }
//
//        let index = Input.readInt(
//            prompt: prompt,
//            validation: [.within(1...options.count)],
//            errorResponse: { input, _ in
//                self.stderr <<< "'\(input)' is invalid; must be a number between 1 and \(options.count)"
//            }
//        )

        return 0
    }

}
