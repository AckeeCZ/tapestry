import SPMUtility
import Basic
import TuistCore
import XCTest
@testable import TapestryCoreTesting
@testable import TapestryKit

final class InitCommandTests: XCTestCase {
    private var subject: InitCommand!
    private var fileHandler: FileHandling!
    private var packageController: MockPackageController!
    private var parser: ArgumentParser!
    
    override func setUp() {
        super.setUp()
        fileHandler = try! MockFileHandler()
        packageController = MockPackageController()
        parser = ArgumentParser.test()
        subject = InitCommand(parser: parser,
                              fileHandler: fileHandler,
                              printer: MockPrinter(),
                              exampleGenerator: MockExampleGenerator(),
                              gitController: MockGitController(),
                              system: MockSystem(),
                              packageController: packageController)
    }
    
    func test_run_when_the_directory_is_not_empty() throws {
        let path = fileHandler.currentPath
        try fileHandler.touch(path.appending(component: "dummy"))

        let result = try parser.parse(["init", "--path", path.pathString])

        XCTAssertThrowsSpecific(try subject.run(with: result), InitCommandError.nonEmptyDirectory(path))
    }
    
    func test_package_initialized_with_name_from_path() throws {
        let name = "test"
        let path = fileHandler.currentPath.appending(component: name)
        
        let result = try parser.parse(["init", "--path", path.pathString])
        
        packageController.stubInitPackage = { _, packageName in
            XCTAssertEqual(name, packageName)
            return .library
        }
        
        try subject.run(with: result)
    }
}

extension ArgumentParser {
    static func test(usage: String = "test",
                     overview: String = "overview") -> ArgumentParser {
        return ArgumentParser(usage: usage, overview: overview)
    }
}

