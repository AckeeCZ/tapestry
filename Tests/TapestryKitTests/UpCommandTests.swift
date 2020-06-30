import XCTest
import TSCBasic
import TSCUtility
@testable import TapestryCoreTesting
@testable import TapestryKit

final class UpCommandTests: TapestryUnitTestCase {
    private var subject: UpCommand!
    private var parser: ArgumentParser!
    private var tapestryConfigGenerator: MocktapestryConfigGenerator!
    
    override func setUp() {
        super.setUp()
        parser = ArgumentParser.test()
        tapestryConfigGenerator = MocktapestryConfigGenerator()
        subject = UpCommand(parser: parser,
                            tapestryConfigGenerator: tapestryConfigGenerator)
    }
    
    func test_opens_project_succeeds() throws {
        // Given
        var generatedPath: AbsolutePath?
        tapestryConfigGenerator.generateTapestryConfigStub = {
            generatedPath = $0
        }
        
        let result = try parser.parse(["up"])
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual(generatedPath, fileHandler.currentPath)
    }
}
