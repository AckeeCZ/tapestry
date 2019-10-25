import XCTest
@testable import TapestryCoreTesting
@testable import PackageDescription

final class ReleaseTests: TapestryUnitTestCase {
    func test_release() {
        // Given
        let subject = Release(actions: [.pre(.docsUpdate)], add: ["File.swift"], commitMessage: "Version \(Argument.version)", push: true)
        
        // Then
        XCTAssertCodable(subject)
    }
}
