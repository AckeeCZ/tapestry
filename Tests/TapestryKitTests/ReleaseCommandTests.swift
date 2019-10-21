import XCTest
import SPMUtility
import Basic
@testable import TapestryGen
@testable import TapestryCore
@testable import TapestryKit
@testable import TapestryCoreTesting

final class ReleaseCommandTests: TapestryUnitTestCase {
    private var subject: ReleaseCommand!
    private var gitController: MockGitController!
    private var parser: ArgumentParser!
    private var configModelLoader: MockConfigModelLoader!
    
    override func setUp() {
        super.setUp()
        
        configModelLoader = MockConfigModelLoader()
        gitController = MockGitController()
        parser = ArgumentParser.test()
        subject = ReleaseCommand(parser: parser,
                                 configModelLoader: configModelLoader,
                                 gitController: gitController,
                                 docsUpdater: MockDocsUpdater(),
                                 dependenciesCompatibilityChecker: MockDependenciesCompatibilityChecker())
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
