import XCTest
import TSCUtility
import TSCBasic
@testable import TapestryGen
@testable import TapestryCore
@testable import TapestryKit
@testable import TapestryCoreTesting

final class ReleaseCommandTests: TapestryUnitTestCase {
    private var subject: ReleaseCommand!
    private var parser: ArgumentParser!
    private var configModelLoader: MockConfigModelLoader!
    private var docsUpdater: MockDocsUpdater!
    private var dependenciesCompatibilityChecker: MockDependenciesCompatibilityChecker!
    
    override func setUp() {
        super.setUp()
        
        configModelLoader = MockConfigModelLoader()
        docsUpdater = MockDocsUpdater()
        dependenciesCompatibilityChecker = MockDependenciesCompatibilityChecker()
        parser = ArgumentParser.test()
        subject = ReleaseCommand(parser: parser,
                                 configModelLoader: configModelLoader,
                                 docsUpdater: docsUpdater,
                                 dependenciesCompatibilityChecker: dependenciesCompatibilityChecker)
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
    
    func test_push_when_false() throws {
        // Given
        configModelLoader.loadTapestryConfigStub = { _ in
            .test(release: .test(push: false))
        }
        let result = try parser.parse(["release", "0.0.1"])
        
        var pushWasCalled: Bool = false
        gitController.pushStub = { _ in
            pushWasCalled = true
        }
        
        var pushTagsWasCalled: Bool = false
        gitController.pushTagsStub = { _ in
            pushTagsWasCalled = true
        }
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertFalse(pushWasCalled)
        XCTAssertFalse(pushTagsWasCalled)
    }
    
    func test_push_when_true() throws {
        // Given
        configModelLoader.loadTapestryConfigStub = { _ in
            .test(release: .test(push: true))
        }
        let result = try parser.parse(["release", "0.0.1"])
        
        var pushWasCalled: Bool = false
        gitController.pushStub = { _ in
            pushWasCalled = true
        }
        
        var pushTagsWasCalled: Bool = false
        gitController.pushTagsStub = { _ in
            pushTagsWasCalled = true
        }
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertTrue(pushWasCalled)
        XCTAssertTrue(pushTagsWasCalled)
    }
    
    func test_run_only_pre_actions_before_commit() throws {
        // Given
        configModelLoader.loadTapestryConfigStub = { _ in
            .test(release: .test(actions: [.init(order: .pre, action: .predefined(.docsUpdate)),
                                           .init(order: .post, action: .predefined(.dependenciesCompatibility([.spm(.all)])))]))
        }
        let result = try parser.parse(["release", "0.0.1"])
        
        var commitWasCalled: Bool = false
        gitController.commitStub = { _, _ in
            commitWasCalled = true
        }
        
        var commitWasCalledWhenDocsUpdate = false
        docsUpdater.updateDocsStub = { _, _ in
            commitWasCalledWhenDocsUpdate = commitWasCalled
        }
        
        var commitWasCalledWhenDependencies = false
        dependenciesCompatibilityChecker.checkCompatibilityStub = { _, _ in
            commitWasCalledWhenDependencies = commitWasCalled
        }
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertFalse(commitWasCalledWhenDocsUpdate)
        XCTAssertTrue(commitWasCalledWhenDependencies)
    }
    
    func test_adds_files() throws {
        // Given
        configModelLoader.loadTapestryConfigStub = { _ in
            .test(release: .test(add: ["readme", "podspec"]))
        }
    
        var addedFiles: [AbsolutePath] = []
        gitController.addStub = { files, _ in
            addedFiles = files
        }
    
        let result = try parser.parse(["release", "0.0.1"])
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual(addedFiles, [fileHandler.currentPath.appending(component: "readme"),
                                    fileHandler.currentPath.appending(component: "podspec")])
    }
}
