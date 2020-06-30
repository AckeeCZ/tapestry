import TSCUtility
import TSCBasic
import XCTest
@testable import TapestryGen
@testable import TapestryCoreTesting
@testable import TapestryKit

final class ActionCommandTests: TapestryUnitTestCase {
    var subject: ActionCommand!
    
    private var parser: ArgumentParser!
    private var docsUpdater: MockDocsUpdater!
    private var dependenciesCompatibilityChecker: MockDependenciesCompatibilityChecker!
    
    override func setUp() {
        super.setUp()
        
        parser = ArgumentParser.test()
        docsUpdater = MockDocsUpdater()
        dependenciesCompatibilityChecker = MockDependenciesCompatibilityChecker()
        subject = ActionCommand(parser: parser,
                                docsUpdater: docsUpdater,
                                dependenciesCompatibilityChecker: dependenciesCompatibilityChecker)
    }
    
    func test_fails_when_invalid_version() throws {
        // Given
        let result = try parser.parse(["action", "docs-update", "0.0.c"])
        
        // Then
        XCTAssertThrowsSpecific(try subject.run(with: result), ActionError.versionInvalid)
    }
    
    func test_updateDocs_succeeds() throws {
        // Given
        let result = try parser.parse(["action", "docs-update", "0.0.1"])
        
        var updateDocsWasCalled: Bool = false
        var updateDocsVersion: Version = Version(0, 0, 0)
        docsUpdater.updateDocsStub = { _, version in
            updateDocsWasCalled = true
            updateDocsVersion = version
        }
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertTrue(updateDocsWasCalled)
        XCTAssertEqual(updateDocsVersion, Version(0, 0, 1))
    }
    
    func test_fails_when_invalid_manager() throws {
        // Given
        let result = try parser.parse(["action", "compatibility", "carthage", "nonspm"])
        
        // Then
        XCTAssertThrowsSpecific(try subject.run(with: result), ActionError.dependenciesInvalid)
    }

    func test_compatibility_succeeds() throws {
        // Given
        let result = try parser.parse(["action", "compatibility", "carthage", "spm", "cocoapods"])
        
        var checkedManagers: [ReleaseAction.DependenciesManager] = []
        dependenciesCompatibilityChecker.checkCompatibilityStub = { managers, _ in
            checkedManagers += managers
        }
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual(checkedManagers, [.carthage, .spm(.all), .cocoapods])
    }
}
