import XCTest
import Basic
@testable import TapestryCoreTesting
@testable import TapestryGen

final class PackageControllerTests: XCTestCase {
    private var subject: PackageController!
    private var system: MockSystem!
    private var inputReader: MockInputReader!
    
    override func setUp() {
        super.setUp()
        inputReader = MockInputReader()
        system = MockSystem()
        subject = PackageController(inputReader: inputReader,
                                    system: system)
    }
    
    
    func test_initPackage_when_library() throws {
        let path = AbsolutePath("/test")
        inputReader.readEnumInputStub = "library"
        system.succeedCommand(["swift", "package", "--package-path", path.pathString, "init", "--library"])
        
        XCTAssertNoThrow(try subject.initPackage(path: path, name: path.components.last ?? ""))
    }
    
    func test_initPackage_when_executable() throws {
        let path = AbsolutePath("/test")
        inputReader.readEnumInputStub = "executable"
        system.succeedCommand(["swift", "package", "--package-path", path.pathString, "init", "--executable"])
        
        XCTAssertNoThrow(try subject.initPackage(path: path, name: path.components.last ?? ""))
    }
    
    func test_initPackage_throws_when_wrong_input() throws {
        let path = AbsolutePath("/test")
        inputReader.readEnumInputStub = "test"
        system.succeedCommand(["swift", "package", "--package-path", path.pathString, "init", "--executable"])
        
        XCTAssertThrowsError(try subject.initPackage(path: path, name: path.components.last ?? ""))
    }
}
