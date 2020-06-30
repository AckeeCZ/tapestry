import XCTest
import TSCBasic
import TuistGenerator
@testable import TapestryGen
@testable import TapestryCoreTesting

final class ExampleGeneratorTests: TapestryUnitTestCase {
    private var subject: ExampleGenerator!
    
    override func setUp() {
        super.setUp()
        
        subject = ExampleGenerator(descriptorGenerator: MockDescriptorGenerator())
    }
    
    func test_folder_for_example_is_created() throws {
        // When
        let temporaryPath = try self.temporaryPath()
        
        try subject.generateProject(
            path: temporaryPath,
            name: "test",
            bundleId: "testBundleId"
        )
        
        // Then
        XCTAssertTrue(fileHandler.exists(temporaryPath.appending(component: ExampleGenerator.exampleAppendix)))
    }
    
    func test_example_sources_are_generated() throws {
        // Given
        let name = "test"
        
        // When
        try subject.generateProject(path: fileHandler.currentPath,
                                    name: name,
                                    bundleId: "testBundleId")
        
        // Then
        let sourcesPath = fileHandler.currentPath.appending(RelativePath("Example/Sources"))
        let exampleContents = try fileHandler.readTextFile(sourcesPath.appending(component: "\(name).swift"))
        XCTAssertTrue(exampleContents.contains(name))
    }
}
