import XCTest
import Basic
import SPMUtility
@testable import TapestryCoreTesting
@testable import TapestryKit

final class GeneateCommandTests: TapestryUnitTestCase {
    private var subject: GenerateCommand!
    private var parser: ArgumentParser!
    private var tapestriesGenerator: MockTapestriesGenerator!
    
    override func setUp() {
        super.setUp()
        parser = ArgumentParser.test()
        tapestriesGenerator = MockTapestriesGenerator()
        subject = GenerateCommand(parser: parser,
                            tapestriesGenerator: tapestriesGenerator)
    }
    
    func test_opens_project_succeeds() throws {
        // Given
        var generatedPath: AbsolutePath?
        tapestriesGenerator.generateTapestriesStub = {
            generatedPath = $0
        }
        
        let result = try parser.parse(["generate"])
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual(generatedPath, fileHandler.currentPath)
    }
}
