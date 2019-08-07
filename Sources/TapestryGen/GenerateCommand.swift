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
        let sources = try TuistGenerator.Target.sources(projectPath: path, sources: [(glob: "Sources/**", compilerFlags: nil)])

        return Project(path: path, name: "Name", settings: .default, filesGroup: .group(name: "Project"), targets: [Target(name: "Target_name", platform: .iOS, product: .app, productName: nil, bundleId: "bundle-id", sources: sources, filesGroup: .group(name: "Project"))], schemes: [])



        //Target(name: <#T##String#>, platform: <#T##Platform#>, product: <#T##Product#>, productName: <#T##String?#>, bundleId: <#T##String#>, infoPlist: <#T##InfoPlist?#>, entitlements: <#T##AbsolutePath?#>, settings: <#T##Settings?#>, sources: <#T##[Target.SourceFile]#>, resources: <#T##[FileElement]#>, headers: <#T##Headers?#>, coreDataModels: <#T##[CoreDataModel]#>, actions: <#T##[TargetAction]#>, environment: <#T##[String : String]#>, filesGroup: <#T##ProjectGroup#>, dependencies: <#T##[Dependency]#>)
    }

    /// We do not use workspace
    func loadWorkspace(at path: AbsolutePath) throws -> Workspace {
        return Workspace(name: "", projects: [])
    }

    func loadTuistConfig(at path: AbsolutePath) throws -> TuistConfig {
        return TuistConfig(generationOptions: [.generateManifest])
    }
    /**
     private func pathTo(_ relativePath: String) -> AbsolutePath {
         return path.appending(RelativePath(relativePath))
     }
    */
}

open class GenerateCommand: SwiftCLI.Command {

    public let name = "generate"
    public let shortDescription = "Generates Swift code for contract"

    public init() {

    }

    public func execute() throws {
        _ = listOptions(["CLI Tool", "Framework"], prompt: "What type of project do you want to create?")

        let generator = Generator(modelLoader: TapestryModelLoader())
        // TODO: Find generated project and do something with files group
        let path = try generator.generateProject(at: AbsolutePath("/Users/marekfort/Development/ackee/TapestryTests"))
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
