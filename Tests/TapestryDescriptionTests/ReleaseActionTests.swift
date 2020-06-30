import XCTest
@testable import TapestryCoreTesting
@testable import TapestryDescription

final class ReleaseActionTests: TapestryUnitTestCase {
    func test_releaseAction_when_pre_and_custom() {
        // Given
        let subject = ReleaseAction(order: .pre, action: .custom(tool: "tool", arguments: ["args"]))
        
        // Then
        XCTAssertCodable(subject)
    }
    
    func test_releaseAction_when_post_and_custom() {
        // Given
        let subject = ReleaseAction(order: .post, action: .custom(tool: "tool", arguments: ["args"]))
        
        // Then
        XCTAssertCodable(subject)
    }
    
    func test_releaseAction_when_pre_and_docsUpdate() {
        // Given
        let subject = ReleaseAction(order: .pre, action: .predefined(.docsUpdate))
        
        // Then
        XCTAssertCodable(subject)
    }
    
    func test_releaseAction_when_post_and_docsUpdate() {
        // Given
        let subject = ReleaseAction(order: .post, action: .predefined(.docsUpdate))
        
        // Then
        XCTAssertCodable(subject)
    }
}
