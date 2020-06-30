import XCTest
import TSCBasic
@testable import TapestryCoreTesting
@testable import TapestryKit

final class UpServiceTests: TapestryUnitTestCase {
    private var subject: UpService!
    private var tapestryConfigGenerator: MocktapestryConfigGenerator!
    
    override func setUp() {
        super.setUp()
        tapestryConfigGenerator = MocktapestryConfigGenerator()
        subject = UpService(
            tapestryConfigGenerator: tapestryConfigGenerator
        )
    }
    
    func test_opens_project_succeeds() throws {
        // Given
        var generatedPath: AbsolutePath?
        tapestryConfigGenerator.generateTapestryConfigStub = {
            generatedPath = $0
        }
        
        // When
        try subject.run(path: nil)
        
        // Then
        XCTAssertEqual(generatedPath, fileHandler.currentPath)
    }
}
