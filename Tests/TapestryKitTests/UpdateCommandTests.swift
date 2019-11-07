import XCTest
import Basic
import SPMUtility
@testable import TapestryCoreTesting
@testable import TapestryKit

final class UpdateCommandTests: TapestryUnitTestCase {
    private var subject: UpdateCommand!
    private var parser: ArgumentParser!
    
    override func setUp() {
        super.setUp()
        parser = ArgumentParser.test()
        subject = UpdateCommand(parser: parser)
    }
    
    func test_update_is_called_with_path() throws {
        // Given
        let path = AbsolutePath("/test")
        var updatePath: AbsolutePath?
        packageController.updateStub = {
            updatePath = $0
        }
        
        let result = try parser.parse(["update", "--path", path.pathString])
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual(updatePath, path)
    }
}
