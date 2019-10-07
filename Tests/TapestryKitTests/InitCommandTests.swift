import SPMUtility
import Basic
import TuistCore
import TapestryCore
import XCTest
@testable import TapestryGen
@testable import TapestryCoreTesting
@testable import TapestryKit

final class InitCommandTests: XCTestCase {
    private var subject: InitCommand!
    private var fileHandler: TapestryCore.FileHandling!
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
        packageController.initPackageStub = { _, packageName in
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
        
        packageController.initPackageStub = { _, _ in
            return .library
        }
        
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
    
    func test_example_not_generated_when_executable() throws {
        // Given
        packageController.initPackageStub = { _, _ in
            return .executable
        }
        var exampleWasGenerated: Bool = false
        exampleGenerator.generateProjectStub = { _, _, _ in
            exampleWasGenerated = true
        }
        
        let result = try parser.parse(["init"])
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertFalse(exampleWasGenerated)
    }
    
    func test_license_is_generated() throws {
        // Given
        let result = try parser.parse(["init"])
        let expectedAuthorName = "Test Name"
        let expectedEmail = "test@test.com"
        inputReader.promptCommand("👋 Author name", output: expectedAuthorName)
        inputReader.promptCommand("💌 Email", output: expectedEmail)
        
        // When
        try subject.run(with: result)
        
        // Then
        let licenseContent = try fileHandler.readTextFile(fileHandler.currentPath.appending(component: "LICENSE"))
        XCTAssertTrue(licenseContent.contains(expectedAuthorName))
        XCTAssertTrue(licenseContent.contains(expectedEmail))
    }
    
    func test_gitignore_is_generated() throws {
        // Given
        let result = try parser.parse(["init"])
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertTrue(fileHandler.exists(fileHandler.currentPath.appending(component: ".gitignore")))
    }
    
    func test_readme_is_generated() throws {
        // Given
        let expectedName = "testPackage"
        let path = fileHandler.currentPath.appending(component: expectedName)
        try fileHandler.createFolder(path)
        let result = try parser.parse(["init", "--path", path.pathString])
        let expectedUsername = "testname"
        inputReader.promptCommand("🍷 Username", output: expectedUsername)
        
        // When
        try subject.run(with: result)
        
        // Then
        let readmeContent = try fileHandler.readTextFile(path.appending(component: "README.md"))
        XCTAssertTrue(readmeContent.contains(expectedName))
        XCTAssertTrue(readmeContent.contains(expectedUsername))
    }
    
    func test_travis_is_generated_when_library() throws {
        // Given
        let expectedName = "testPackage"
        let path = fileHandler.currentPath.appending(component: expectedName)
        try fileHandler.createFolder(path)
        packageController.initPackageStub = { _, _ in
            return .library
        }
        let result = try parser.parse(["init", "--path", path.pathString])
        
        // When
        try subject.run(with: result)
        
        // Then
        let travisContent = try fileHandler.readTextFile(path.appending(component: ".travis.yml"))
        XCTAssertTrue(travisContent.contains(expectedName))
        XCTAssertTrue(travisContent.contains(expectedName + ExampleGenerator.exampleAppendix))
    }
    
    func test_travis_is_generated_when_executable() throws {
        // Given
        let expectedName = "testPackage"
        let path = fileHandler.currentPath.appending(component: expectedName)
        try fileHandler.createFolder(path)
        packageController.initPackageStub = { _, _ in
            return .executable
        }
        let result = try parser.parse(["init", "--path", path.pathString])
        
        // When
        try subject.run(with: result)
        
        // Then
        let travisContent = try fileHandler.readTextFile(path.appending(component: ".travis.yml"))
        XCTAssertTrue(travisContent.contains(expectedName))
        XCTAssertFalse(travisContent.contains(expectedName + ExampleGenerator.exampleAppendix))
    }
    
    func test_package_xcodeProj_is_generated() throws {
        // Given
        var path: AbsolutePath?
        packageController.generateXcodeprojStub = {
            path = $0
        }
        let result = try parser.parse(["init"])
        
        // When
        try subject.run(with: result)
        
        // Then
        XCTAssertEqual(fileHandler.currentPath, path)
    }
}
