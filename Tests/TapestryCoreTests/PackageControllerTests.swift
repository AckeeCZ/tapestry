import XCTest
import Basic
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
    
    func test_runs_succeeds() throws {
        // Given
        let tool = "testtool"
        let arguments = ["arg", "arg2"]
        system.succeedCommand(["swift", "run", tool])
        let debugPath = fileHandler.currentPath.appending(RelativePath("Tapestries/.build/x86_64-apple-macosx/debug/"))
        let toolPath = fileHandler.currentPath.appending(component: tool)
        try fileHandler.createFolder(debugPath)
        try fileHandler.touch(debugPath.appending(component: tool))
        system.succeedCommand([toolPath.pathString] + arguments)
        
        // Then
        XCTAssertNoThrow(try subject.run(tool, arguments: arguments, path: fileHandler.currentPath))
    }
}
