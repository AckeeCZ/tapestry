import XCTest
import Basic
import SPMUtility
@testable import TapestryCoreTesting
@testable import TapestryKit

final class RunCommandTests: TapestryUnitTestCase {
    private var subject: RunCommand!
    private var parser: ArgumentParser!
    override func setUp() {
        super.setUp()
        parser = ArgumentParser.test()
        subject = RunCommand(parser: parser)
    }
    
    func test_run_succeeds_without_arguments() throws {
        // Given
        let expectedTool = "executable"
        var runTool = ""
        packageController.runStub = { tool, _, _ in
            runTool = tool
        }
        
        let result = try parser.parse(["run", expectedTool])
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual(runTool, expectedTool)
    }
    
    func test_run_succeeds_with_arguments() throws {
        // Given
        let expectedTool = "executable"
        let expectedArguments = [".", "all"]
        var runTool = ""
        var runArguments: [String] = []
        packageController.runStub = { tool, arguments, _ in
            runTool = tool
            runArguments = arguments
        }
        
        let result = try parser.parse(["run", expectedTool] + expectedArguments)
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual(runTool, expectedTool)
        XCTAssertEqual(runArguments, expectedArguments)
    }
}
