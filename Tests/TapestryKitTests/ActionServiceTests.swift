import TSCBasic
import XCTest
import TSCUtility
@testable import TapestryGen
@testable import TapestryCoreTesting
@testable import TapestryKit

final class ActionServiceTests: TapestryUnitTestCase {
    private var subject: ActionService!
    
    private var docsUpdater: MockDocsUpdater!
    private var dependenciesCompatibilityChecker: MockDependenciesCompatibilityChecker!
    
    override func setUp() {
        super.setUp()
        
        docsUpdater = MockDocsUpdater()
        dependenciesCompatibilityChecker = MockDependenciesCompatibilityChecker()
        subject = ActionService(
            docsUpdater: docsUpdater,
            dependenciesCompatibilityChecker: dependenciesCompatibilityChecker
        )
    }
    
    func test_fails_when_invalid_version() throws {
        XCTAssertThrowsSpecific(
            try subject.run(
                path: nil,
                action: .docsUpdate,
                actionArguments: ["0.0.c"]
            ),
            ActionError.versionInvalid
        )
    }
    
    func test_updateDocs_succeeds() throws {
        // Given
        var updateDocsWasCalled: Bool = false
        var updateDocsVersion: Version = Version(0, 0, 0)
        docsUpdater.updateDocsStub = { _, version in
            updateDocsWasCalled = true
            updateDocsVersion = version
        }
        
        // When
        try subject.run(
            path: nil,
            action: .docsUpdate,
            actionArguments: ["0.0.1"]
        )
        
        // Then
        XCTAssertTrue(updateDocsWasCalled)
        XCTAssertEqual(updateDocsVersion, Version(0, 0, 1))
    }
    
    func test_fails_when_invalid_manager() throws {
        XCTAssertThrowsSpecific(
            try subject.run(
                path: nil,
                action: .dependenciesCompatibility,
                actionArguments: ["carthage", "nospm"]
            ),
            ActionError.dependenciesInvalid
        )
    }
    
    func test_compatibility_succeeds() throws {
        // Given        
        var checkedManagers: [ReleaseAction.DependenciesManager] = []
        dependenciesCompatibilityChecker.checkCompatibilityStub = { managers, _ in
            checkedManagers += managers
        }
        
        // When
        try subject.run(
            path: nil,
            action: .dependenciesCompatibility,
            actionArguments: ["carthage", "spm", "cocoapods"]
        )
        
        // Then
        XCTAssertEqual(checkedManagers, [.carthage, .spm(.all), .cocoapods])
    }
}
