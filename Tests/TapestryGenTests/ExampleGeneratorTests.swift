import XCTest
import Basic
import TuistGenerator
@testable import TapestryGen
@testable import TapestryCoreTesting

final class ExampleGeneratorTests: XCTestCase {
    private var subject: ExampleGenerator!
    private var fileHandler: MockFileHandler!
    
    override func setUp() {
        super.setUp()
        
        fileHandler = try! MockFileHandler()
        subject = ExampleGenerator(fileHandler: fileHandler, generatorInit: { name, bundleId -> Generating in
            return MockGenerator()
        })
    }
    
    func test_folder_for_example_is_created() throws {
        // When
        try subject.generateProject(path: fileHandler.currentPath,
                                    name: "test",
                                    bundleId: "testBundleId")
        
        // Then
        XCTAssertTrue(fileHandler.exists(fileHandler.currentPath.appending(component: ExampleGenerator.exampleAppendix)))
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
    
    func test_generator_generates_project() throws {
        // Given
        var generatedProjectPath: AbsolutePath?
        let subject = ExampleGenerator(fileHandler: try MockFileHandler(), generatorInit: { name, bundleId -> Generating in
            let generator = MockGenerator()
            generator.generateProjectStub = {
                generatedProjectPath = $0
                return generatedProjectPath ?? AbsolutePath("/test")
            }
            return generator
        })
        
        // When
        try subject.generateProject(path: fileHandler.currentPath,
                                    name: "test",
                                    bundleId: "testBundleId")
        
        // Then
        XCTAssertEqual(fileHandler.currentPath.appending(RelativePath(ExampleGenerator.exampleAppendix)), generatedProjectPath)
    }
}
