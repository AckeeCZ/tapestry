import XCTest
import Basic
import SPMUtility
@testable import TapestryCore
@testable import TapestryCoreTesting

final class DocsUpdaterTests: TapestryUnitTestCase {
    var subject: DocsUpdater!
    
    override func setUp() {
        super.setUp()
        subject = DocsUpdater()
    }
    
    func test_updateVersionInPodspec() throws {
        // Given
        let content = """
        s.version = "0.0.1"
        s.dependency "BigInt", "~> 0.0.1"
        """
        let name = "TestPackage"
        let path = fileHandler.currentPath.appending(component: name)
        try fileHandler.createFolder(path)
        let podspecPath = path.appending(component: "\(name).podspec")
        try content.write(to: podspecPath.url, atomically: true, encoding: .utf8)
        
        packageController.nameStub = { _ in
            name
        }

        // When
        try subject.updateDocs(path: path, version: Version(1, 0, 0))

        // Then
        let expectedContent = """
        s.version = "1.0.0"
        s.dependency "BigInt", "~> 0.0.1"
        """
        XCTAssertEqual(try fileHandler.readTextFile(podspecPath), expectedContent)
    }

    func test_updateVersionInReadme() throws {
        // Given
        let content = """
        Just add this to your `Package.swift`:
        ```swift
        .package(url: "https://github.com/marek.fort/TestPackage.git", .upToNextMajor(from: "0.0.1")),
        ```

        ```ruby
        pod "TestPackage", "~> 0.0.1"
        pod "Random", "~> 0.0.1"
        ```
        """
        let name = "TestPackage"
        let path = fileHandler.currentPath.appending(component: name)
        try fileHandler.createFolder(path)
        let readmePath = path.appending(component: "README.md")
        try content.write(to: readmePath.url, atomically: true, encoding: .utf8)
    
        packageController.nameStub = { _ in
            name
        }

        // When
        try subject.updateDocs(path: path, version: Version(1, 0, 0))

        // Then
        let expectedContent = """
        Just add this to your `Package.swift`:
        ```swift
        .package(url: "https://github.com/marek.fort/TestPackage.git", .upToNextMajor(from: "1.0.0")),
        ```

        ```ruby
        pod "TestPackage", "~> 1.0.0"
        pod "Random", "~> 0.0.1"
        ```
        """
        XCTAssertEqual(try fileHandler.readTextFile(readmePath), expectedContent)
    }
}
