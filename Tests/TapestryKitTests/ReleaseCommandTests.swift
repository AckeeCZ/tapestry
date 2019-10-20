import XCTest
import SPMUtility
import Basic
@testable import TapestryCore
@testable import TapestryKit
@testable import TapestryCoreTesting

final class ReleaseCommandTests: TapestryUnitTestCase {
    private var subject: ReleaseCommand!
    private var gitController: MockGitController!
    private var parser: ArgumentParser!
    
    override func setUp() {
        super.setUp()
        
        gitController = MockGitController()
        parser = ArgumentParser.test()
        subject = ReleaseCommand(parser: parser,
                                 gitController: gitController,
                                 docsUpdater: MockDocsUpdater(),
                                 packageController: MockPackageController())
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
        let version = "1.0.0"
        let result = try parser.parse(["release", version, "--path", path.pathString])
        
        // When
        try subject.run(with: result)
        
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
        let version = "1.0.0"
        let result = try parser.parse(["release", version, "--path", path.pathString])
        
        // When
        try subject.run(with: result)
        
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
    
    func test_version_is_commited() throws {
        // Given
        let path = fileHandler.currentPath.appending(component: "test")
        try fileHandler.createFolder(path)
        let result = try parser.parse(["release", "0.0.1", "--path", path.pathString])
        
        var message: String?
        var commitPath: AbsolutePath?
        gitController.commitStub = {
            message = $0
            commitPath = $1
        }
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual("Version 0.0.1", message)
        XCTAssertEqual(commitPath, path)
    }
    
    func test_version_is_tagged() throws {
        // Given
        let path = fileHandler.currentPath.appending(component: "test")
        try fileHandler.createFolder(path)
        let result = try parser.parse(["release", "0.0.1", "--path", path.pathString])
        
        var version: Version?
        var tagPath: AbsolutePath?
        gitController.tagVersionStub = {
            version = $0
            tagPath = $1
        }
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual("0.0.1", version?.description)
        XCTAssertEqual(tagPath, path)
    }
    
    func test_version_is_tagged_after_commit() throws {
        // Given
        let result = try parser.parse(["release", "0.0.1"])
        
        var tagWasCalled: Bool = false
        var commitWasCalled: Bool = false
        gitController.commitStub = { _, _ in
            XCTAssertFalse(tagWasCalled)
            XCTAssertFalse(commitWasCalled)
            commitWasCalled = true
        }
        gitController.tagVersionStub = { _, _ in
            XCTAssertTrue(commitWasCalled)
            XCTAssertFalse(tagWasCalled)
            tagWasCalled = true
        }
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertTrue(tagWasCalled)
        XCTAssertTrue(commitWasCalled)
    }
    
    func test_error_when_version_exists() throws {
        // Given
        let version = Version(0, 0, 1)
        let result = try parser.parse(["release", version.description])
        
        gitController.tagExistsStub = { _, _ in
            true
        }
        
        // Then
        XCTAssertThrowsSpecific(try subject.run(with: result), ReleaseError.tagExists(version))
    }
}
