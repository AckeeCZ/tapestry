import XCTest
import Basic
import SPMUtility
@testable import TapestryCoreTesting
@testable import TapestryKit

final class EditCommandTests: TapestryUnitTestCase {
    private var subject: EditCommand!
    private var parser: ArgumentParser!
    
    override func setUp() {
        super.setUp()
        parser = ArgumentParser.test()
        subject = EditCommand(parser: parser)
    }
    
    func test_opens_project_succeeds() throws {
        // Given
        var openedPath: AbsolutePath?
        xcodeController.openStub = {
            openedPath = $0
        }
        
        let result = try parser.parse(["edit"])
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual(fileHandler.currentPath.appending(component: "Tapestries"), openedPath)
    }
}
