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
    private let packageName: String
    private let name: String

    init(packageName: String, name: String) {
        self.packageName = packageName
        self.name = name
    }

    func loadProject(at path: AbsolutePath) throws -> Project {
        // TODO: Add local package
        let sources = try TuistGenerator.Target.sources(projectPath: path, sources: [(glob: "Sources/**", compilerFlags: nil)])
        return Project(path: path, name: name, settings: .default, filesGroup: .group(name: name), targets: [Target(name: name, platform: .iOS, product: .app, productName: nil, bundleId: "ackee." + String(name), sources: sources, filesGroup: .group(name: name), dependencies: [.framework(path: RelativePath("../../\(packageName)"))])], schemes: [])
    }

    /// We do not use workspace
    func loadWorkspace(at path: AbsolutePath) throws -> Workspace {
        return Workspace(name: "", projects: [])
    }

    func loadTuistConfig(at path: AbsolutePath) throws -> TuistConfig {
        return TuistConfig(compatibleXcodeVersions: .all, generationOptions: [.generateManifest])
    }
}
