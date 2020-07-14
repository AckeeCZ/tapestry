import TSCUtility
import XCTest
@testable import TapestryCore
@testable import TapestryCoreTesting

final class ChangelogGeneratorTests: TapestryUnitTestCase {
    var subject: ChangelogGenerator!
    
    override func setUp() {
        super.setUp()
        
        subject = ChangelogGenerator()
    }
    
    func testGeneratesChangelog() throws {
        // Given
        let path = try temporaryPath()
        let changelogPath = path.appending(component: "CHANGELOG.md")
        
        let changelog = """
        ## Next

        ### 1.0.0
        
        ### Changed
        - Changed something
        
        ### 0.1.0
        - Something different

        ### 0.0.1
        - Something else
        """
        
        try changelog.write(to: changelogPath.url, atomically: true, encoding: .utf8)
        
        // When
        let got = try subject.generateChangelog(
            for: Version(1, 0, 0),
            path: path
        )
        
        // Then
        XCTAssertEqual(
            got,
            """
            ### 1.0.0
            
            ### Changed
            - Changed something
            """
        )
    }
    
    func testGenerateChangelogWhenNoOldVersion() throws {
        // Given
        let path = try temporaryPath()
        let changelogPath = path.appending(component: "CHANGELOG.md")
        
        let changelog = """
        ## Next

        ### 1.0.0
        
        ### Changed
        - Changed something
        """
        
        try changelog.write(to: changelogPath.url, atomically: true, encoding: .utf8)
        
        // When
        let got = try subject.generateChangelog(
            for: Version(1, 0, 0),
            path: path
        )
        
        // Then
        XCTAssertEqual(
            got,
            """
            ### 1.0.0
            
            ### Changed
            - Changed something
            """
        )
    }
    
    func testGenerateChangelogWhenNewVersionNotFound() throws {
        // Given
        let path = try temporaryPath()
        let changelogPath = path.appending(component: "CHANGELOG.md")
        
        let changelog = """
        ## Next
        
        ### Changed
        - Changed something
        
        ### 0.1.0
        - Something different

        ### 0.0.1
        - Something else
        """
        
        try changelog.write(to: changelogPath.url, atomically: true, encoding: .utf8)
        
        // Then
        XCTAssertThrowsSpecific(
            try subject.generateChangelog(
                for: Version(1, 0, 0),
                path: path
            ),
            ChangelogGeneratorError.newVersionNotFound(Version(1, 0, 0))
        )
    }
}
