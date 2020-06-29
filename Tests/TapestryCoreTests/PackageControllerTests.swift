import XCTest
import TSCBasic
@testable import TapestryCoreTesting
@testable import TapestryCore

final class PackageControllerTests: TapestryUnitTestCase {
    private var subject: PackageController!
    
    override func setUp() {
        super.setUp()
        subject = PackageController()
    }
    
    
    func test_initPackage_when_library() throws {
        let path = AbsolutePath("/test")
        inputReader.readEnumInputStub = {
            "library"
        }
        system.succeedCommand(["swift", "package", "--package-path", path.pathString, "init", "--type" , "library"])
        
        XCTAssertNoThrow(try subject.initPackage(path: path, name: path.components.last ?? ""))
    }
    
    func test_initPackage_when_executable() throws {
        let path = AbsolutePath("/test")
        inputReader.readEnumInputStub = {
            "executable"
        }
        system.succeedCommand(["swift", "package", "--package-path", path.pathString, "init", "--type", "executable"])
        
        XCTAssertNoThrow(try subject.initPackage(path: path, name: path.components.last ?? ""))
    }
    
    func test_initPackage_throws_when_wrong_input() throws {
        let path = AbsolutePath("/test")
        inputReader.readEnumInputStub = {
            throw NSError.test()
        }
        system.succeedCommand(["swift", "package", "--package-path", path.pathString, "init", "--type", "library"])
        
        XCTAssertThrowsError(try subject.initPackage(path: path, name: path.components.last ?? ""))
    }
    
    func test_name_succeeds() throws {
        // Given
        let name = "test"
        
        // Then
        XCTAssertEqual(try subject.name(from: fileHandler.currentPath.appending(component: name)), name)
    }
    
    func test_update_succeeds() throws {
        // Given
        let path = AbsolutePath("/test")
        system.succeedCommand("swift", "package", "--package-path", path.pathString, "update")
        
        // Then
        XCTAssertNoThrow(try subject.update(path: path))
    }
    
    func test_update_fails() throws {
        // Given
        let path = AbsolutePath("/test")
        system.errorCommand("swift", "package", "--package-path", path.pathString, "update")
        
        // Then
        XCTAssertThrowsError(try subject.update(path: path))
    }
}
