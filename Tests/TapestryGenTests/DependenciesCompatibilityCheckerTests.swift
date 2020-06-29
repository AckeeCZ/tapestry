import XCTest
import TSCBasic
@testable import TapestryCoreTesting
@testable import TapestryGen

final class DependenciesCompatibilityCheckerTests: TapestryUnitTestCase {
    private var subject: DependenciesCompatibilityChecker!
    
    override func setUp() {
        super.setUp()
        subject = DependenciesCompatibilityChecker()
    }
    
    func test_check_succeeds_when_carthage() {
        // Given
        system.succeedCommand(["carthage", "build", "--no-skip-current"])
        
        // Then
        XCTAssertNoThrow(try subject.checkCompatibility(with: [.carthage], path: fileHandler.currentPath))
    }
    
    func test_check_fails_when_carthage() {
        // Given
        system.errorCommand(["carthage", "build", "--no-skip-current"])
        
        // Then
        XCTAssertThrowsError(try subject.checkCompatibility(with: [.carthage], path: fileHandler.currentPath))
    }
    
    func test_check_succeeds_when_cocoapods() {
        // Given
        system.succeedCommand(["pod", "lib", "lint", "--allow-warnings"])
        
        // Then
        XCTAssertNoThrow(try subject.checkCompatibility(with: [.cocoapods], path: fileHandler.currentPath))
    }
    
    func test_check_fails_when_cocoapods() {
        // Given
        system.errorCommand(["pod", "lib", "lint", "--allow-warnings"])
        
        // Then
        XCTAssertThrowsError(try subject.checkCompatibility(with: [.cocoapods], path: fileHandler.currentPath))
    }
    
    func test_check_succeeds_when_spm() {
        // Given
        system.succeedCommand(["swift", "build"])
        
        // Then
        XCTAssertNoThrow(try subject.checkCompatibility(with: [.spm(.all)], path: fileHandler.currentPath))
    }
    
    func test_check_fails_when_spm() {
        // Given
        xcodeController.buildStub = { _, _, _ in
            throw NSError.test()
        }
        // Then
        XCTAssertThrowsError(try subject.checkCompatibility(with: [.spm(.all)], path: fileHandler.currentPath))
    }
}
