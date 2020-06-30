import XCTest
import TSCUtility
import TSCBasic
@testable import TapestryGen
@testable import TapestryCore
@testable import TapestryKit
@testable import TapestryCoreTesting

final class ReleaseServiceTests: TapestryUnitTestCase {
    private var subject: ReleaseService!
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
        subject = ReleaseService(
            configModelLoader: configModelLoader,
            docsUpdater: docsUpdater,
            dependenciesCompatibilityChecker: dependenciesCompatibilityChecker
        )
    }
    
    func test_version_is_commited() throws {
        // Given
        let path = fileHandler.currentPath.appending(component: "test")
        try fileHandler.createFolder(path)
        
        var message: String?
        var commitPath: AbsolutePath?
        gitController.commitStub = {
            message = $0
            commitPath = $1
        }
        
        // When
        try subject.run(
            path: path.pathString,
            version: Version(0, 0, 1)
        )
        
        // Then
        XCTAssertEqual("Version 0.0.1", message)
        XCTAssertEqual(commitPath, path)
    }
    
    func test_version_is_tagged() throws {
        // Given
        let path = fileHandler.currentPath.appending(component: "test")
        try fileHandler.createFolder(path)

        var version: Version?
        var tagPath: AbsolutePath?
        gitController.tagVersionStub = {
            version = $0
            tagPath = $1
        }

        // When
        try subject.run(
            path: path.pathString,
            version: Version(0, 0, 1)
        )

        // Then
        XCTAssertEqual("0.0.1", version?.description)
        XCTAssertEqual(tagPath, path)
    }

    func test_version_is_tagged_after_commit() throws {
        // Given
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
        try subject.run(
            path: nil,
            version: Version(0, 0, 1)
        )

        // Then
        XCTAssertTrue(tagWasCalled)
        XCTAssertTrue(commitWasCalled)
    }

    func test_error_when_version_exists() throws {
        // Given
        let version = Version(0, 0, 1)
        gitController.tagExistsStub = { _, _ in
            true
        }

        // Then
        XCTAssertThrowsSpecific(
            try subject.run(
                path: nil,
                version: version
            ),
            ReleaseError.tagExists(version)
        )
    }

    func test_push_when_false() throws {
        // Given
        configModelLoader.loadTapestryConfigStub = { _ in
            .test(release: .test(push: false))
        }

        var pushWasCalled: Bool = false
        gitController.pushStub = { _ in
            pushWasCalled = true
        }

        var pushTagsWasCalled: Bool = false
        gitController.pushTagsStub = { _ in
            pushTagsWasCalled = true
        }

        // When
        try subject.run(
            path: nil,
            version: Version(0, 0, 1)
        )

        // Then
        XCTAssertFalse(pushWasCalled)
        XCTAssertFalse(pushTagsWasCalled)
    }

    func test_push_when_true() throws {
        // Given
        configModelLoader.loadTapestryConfigStub = { _ in
            .test(release: .test(push: true))
        }

        var pushWasCalled: Bool = false
        gitController.pushStub = { _ in
            pushWasCalled = true
        }

        var pushTagsWasCalled: Bool = false
        gitController.pushTagsStub = { _ in
            pushTagsWasCalled = true
        }

        // When
        try subject.run(
            path: nil,
            version: Version(0, 0, 1)
        )

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
        try subject.run(
            path: nil,
            version: Version(0, 0, 1)
        )

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

        // When
        try subject.run(
            path: nil,
            version: Version(0, 0, 1)
        )

        // Then
        XCTAssertEqual(addedFiles, [fileHandler.currentPath.appending(component: "readme"),
                                    fileHandler.currentPath.appending(component: "podspec")])
    }
}
