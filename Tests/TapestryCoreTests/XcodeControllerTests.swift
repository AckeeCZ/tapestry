import Basic
import XCTest
@testable import TapestryCore
@testable import TapestryCoreTesting

final class XcodeControllerTests: TapestryUnitTestCase {
    private var subject: XcodeController!
    
    override func setUp() {
        super.setUp()
        subject = XcodeController()
    }
    
    func test_open_succeeds() {
        // Given
        let projectPath = AbsolutePath("/project.proj")
        system.succeedCommand(["xed", projectPath.pathString])
        
        // Then
        XCTAssertNoThrow(try subject.open(at: projectPath))
    }
}
