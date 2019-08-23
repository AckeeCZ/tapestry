//
//  ExampleGenerator.swift
//  AEXML
//
//  Created by Marek Fořt on 8/23/19.
//

import Foundation
import TuistGenerator
import Basic
import TuistCore

protocol ExampleGenerating {
    func generateProject(path: AbsolutePath, name: String) throws
}

class ExampleGenerator: ExampleGenerating {

    private let fileHandler: FileHandling

    init(fileHandler: FileHandling) {
        self.fileHandler = fileHandler
    }

    // MARK: - Public methods

    func generateProject(path: AbsolutePath, name: String) throws {
        let examplePath = path.appending(RelativePath("Example"))
        try fileHandler.createFolder(examplePath)

        try createExampleSources(path: examplePath, name: name)

        let generator = Generator(modelLoader: ExampleModelLoader(name: name))
        _ = try generator.generateProject(at: examplePath)
    }

    // MARK: - Helpers

    private func createExampleSources(path: AbsolutePath, name: String) throws {
        let sourcesPath = path.appending(RelativePath("Sources"))
        try fileHandler.createFolder(sourcesPath)
        try generateExampleSourceFile(path: sourcesPath, name: name)
    }

    private func generateExampleSourceFile(path: AbsolutePath, name: String) throws {
            let content = """
            struct \(name) {
                var text = "Hello, World!"
            }
            """
            try content.write(to: path.appending(component: "\(name).swift").url, atomically: true, encoding: .utf8)
        }
}
