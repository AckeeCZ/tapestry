//
//  ExampleModelLoader.swift
//  AEXML
//
//  Created by Marek Fořt on 8/23/19.
//

import Foundation
import Basic
import TuistGenerator

class ExampleModelLoader: GeneratorModelLoading {
    private let name: String

    init(name: String) {
        self.name = name
    }

    func loadProject(at path: AbsolutePath) throws -> Project {
        let sources = try TuistGenerator.Target.sources(projectPath: path, sources: [(glob: "Sources/**", compilerFlags: nil)])

        return Project(path: path, name: name, settings: .default, filesGroup: .group(name: name), targets: [Target(name: name, platform: .iOS, product: .app, productName: nil, bundleId: "ackee." + String(name), sources: sources, filesGroup: .group(name: name))], schemes: [])
    }

    /// We do not use workspace
    func loadWorkspace(at path: AbsolutePath) throws -> Workspace {
        return Workspace(name: "", projects: [])
    }

    func loadTuistConfig(at path: AbsolutePath) throws -> TuistConfig {
        return TuistConfig(compatibleXcodeVersions: .all, generationOptions: [.generateManifest])
    }
}
