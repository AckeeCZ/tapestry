import XCTest
import Basic
import SPMUtility
import TapestryCore
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
        let path = fileHandler.currentPath.appending(component: "test")
        var updatePath: AbsolutePath?
        packageController.updateStub = {
            updatePath = $0
        }
        let tapestriesPath = path.appending(component: Constants.tapestriesName)
        try fileHandler.createFolder(tapestriesPath)
        
        let result = try parser.parse(["update", "--path", path.pathString])
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual(updatePath, tapestriesPath)
    }
    
    func test_update_fails_when_tapestries_not_found() throws {
        // Given
        let result = try parser.parse(["update"])
        
        // Then
        XCTAssertThrowsSpecific(try subject.run(with: result),
                                UpdateError.tapestriesFolderMissing(fileHandler.currentPath.appending(component: Constants.tapestriesName)))
        
    }
}
