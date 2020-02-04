import XCTest
import Basic
import SPMUtility
@testable import TapestryCoreTesting
@testable import TapestryKit

final class UpCommandTests: TapestryUnitTestCase {
    private var subject: UpCommand!
    private var parser: ArgumentParser!
    private var tapestriesGenerator: MockTapestriesGenerator!
    
    override func setUp() {
        super.setUp()
        parser = ArgumentParser.test()
        tapestriesGenerator = MockTapestriesGenerator()
        subject = UpCommand(parser: parser,
                            tapestriesGenerator: tapestriesGenerator)
    }
    
    func test_opens_project_succeeds() throws {
        // Given
        var generatedPath: AbsolutePath?
        tapestriesGenerator.generateTapestryConfigStub = {
            generatedPath = $0
        }
        
        let result = try parser.parse(["up"])
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual(generatedPath, fileHandler.currentPath)
    }
}
