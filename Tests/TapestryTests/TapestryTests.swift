import XCTest
@testable import Tapestry

final class TapestryTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Tapestry().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
