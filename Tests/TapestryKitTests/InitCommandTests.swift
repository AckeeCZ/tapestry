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
    private var gitController: MockGitController!
    private var inputReader: MockInputReader!
    private var exampleGenerator: MockExampleGenerator!
    private var parser: ArgumentParser!
    
    override func setUp() {
        super.setUp()
        fileHandler = try! MockFileHandler()
        packageController = MockPackageController()
        gitController = MockGitController()
        inputReader = MockInputReader()
        exampleGenerator = MockExampleGenerator()
        parser = ArgumentParser.test()
        subject = InitCommand(parser: parser,
                              fileHandler: fileHandler,
                              printer: MockPrinter(),
                              exampleGenerator: exampleGenerator,
                              gitController: gitController,
                              system: MockSystem(),
                              packageController: packageController,
                              inputReader: inputReader)
    }
    
    func test_run_when_the_directory_is_not_empty() throws {
        let path = fileHandler.currentPath
        try fileHandler.touch(path.appending(component: "dummy"))

        let result = try parser.parse(["init", "--path", path.pathString])

        XCTAssertThrowsSpecific(try subject.run(with: result), InitCommandError.nonEmptyDirectory(path))
    }
    
    func test_package_initialized_with_name_from_path() throws {
        // Given
        let name = "test"
        let path = fileHandler.currentPath.appending(component: name)
        try fileHandler.createFolder(path)
        
        let result = try parser.parse(["init", "--path", path.pathString])
        
        var initializedPackageName: String?
        packageController.stubInitPackage = { _, packageName in
            initializedPackageName = packageName
            return .library
        }
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual(name, initializedPackageName)
    }
    
    func test_git_initialized() throws {
        // Given
        var initGitPath: AbsolutePath?
        gitController.initGitStub = {
            initGitPath = $0
        }
        
        let result = try parser.parse(["init"])
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual(initGitPath, fileHandler.currentPath)
    }
    
    func test_generateProject_when_library() throws {
        // Given
        let name = "test"
        let path = fileHandler.currentPath.appending(component: name)
        try fileHandler.createFolder(path)
        var examplePath: AbsolutePath?
        var exampleName: String?
        var exampleBundleId: String?
        let expectedBundleId = "testBundleId"
        
        inputReader.promptCommand("📝 Bundle ID", output: expectedBundleId)
        
        exampleGenerator.generateProjectStub = { path, name, bundleId in
            examplePath = path
            exampleName = name
            exampleBundleId = bundleId
        }
        
        let result = try parser.parse(["init", "--path", path.pathString])
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual(examplePath, path)
        XCTAssertEqual(exampleName, name)
        XCTAssertEqual(exampleBundleId, expectedBundleId)
    }
}

extension ArgumentParser {
    static func test(usage: String = "test",
                     overview: String = "overview") -> ArgumentParser {
        return ArgumentParser(usage: usage, overview: overview)
    }
}

