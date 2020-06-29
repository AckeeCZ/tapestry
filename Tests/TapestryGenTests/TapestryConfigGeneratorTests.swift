import XCTest
import TSCBasic
@testable import TapestryCore
@testable import TapestryCoreTesting
@testable import TapestryGen

final class TapestryConfigGeneratorTests: TapestryUnitTestCase {
    var subject: TapestryConfigGenerator!
    
    override func setUp() {
        super.setUp()
        subject = TapestryConfigGenerator()
    }
    
    func test_generate_tapestryConfig() throws {
        // Given
        packageController.nameStub = { _ in
            "TapestryDemo"
        }
        let tapestryConfigPath = fileHandler.currentPath.appending(component: "TapestryConfig.swift")
        let expectedContents = """
        import TapestryDescription

        let config = TapestryConfig(release: Release(actions: [.pre(.docsUpdate),
                                                               .pre(.dependenciesCompatibility([.cocoapods, .carthage, .spm(.all)]))],
                                                     add: ["README.md",
                                                           "TapestryDemo.podspec",
                                                           "CHANGELOG.md"],
                                                     commitMessage: "Version \\(Argument.version)",
                                                     push: false))

        """
        
        // When
        try subject.generateTapestryConfig(at: fileHandler.currentPath)
        
        // Then
        XCTAssertEqual(try fileHandler.readTextFile(tapestryConfigPath), expectedContents)
    }
}
