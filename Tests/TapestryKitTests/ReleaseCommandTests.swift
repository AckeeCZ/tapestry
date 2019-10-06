import XCTest
import SPMUtility
@testable import TapestryKit
@testable import TapestryCoreTesting

final class ReleaseCommandTests: XCTestCase {
    private var subject: ReleaseCommand!
    private var fileHandler: MockFileHandler!
    private var parser: ArgumentParser!
    
    override func setUp() {
        super.setUp()
        
        fileHandler = try! MockFileHandler()
        parser = ArgumentParser.test()
        subject = ReleaseCommand(parser: parser)
    }
    
    func test_updateVersionInPodspec() throws {
        // Given
        let content = """
        s.version = "0.0.1"
        s.dependency "BigInt", "~> 0.0.1"
        """
        let name = "TestPackage"
        let path = fileHandler.currentPath.appending(component: name)
        try fileHandler.createFolder(path)
        let podspecPath = path.appending(component: "\(name).podspec")
        try content.write(to: podspecPath.url, atomically: true, encoding: .utf8)
        let version = "1.0.0"
        let result = try parser.parse(["release", version, "--path", path.pathString])
        
        // When
        try subject.run(with: result)
        
        // Then
        let expectedContent = """
        s.version = "1.0.0"
        s.dependency "BigInt", "~> 0.0.1"
        """
        XCTAssertEqual(try fileHandler.readTextFile(podspecPath), expectedContent)
    }
    
    func test_updateVersionInReadme() throws {
        // Given
        let content = """
        Just add this to your `Package.swift`:
        ```swift
        .package(url: "https://github.com/marek.fort/TestPackage.git", .upToNextMajor(from: "0.0.1")),
        ```

        ```ruby
        pod "TestPackage", "~> 0.0.1"
        pod "Random", "~> 0.0.1"
        ```
        """
        let name = "TestPackage"
        let path = fileHandler.currentPath.appending(component: name)
        try fileHandler.createFolder(path)
        let readmePath = path.appending(component: "README.md")
        try content.write(to: readmePath.url, atomically: true, encoding: .utf8)
        let version = "1.0.0"
        let result = try parser.parse(["release", version, "--path", path.pathString])
        
        // When
        try subject.run(with: result)
        
        // Then
        let expectedContent = """
        Just add this to your `Package.swift`:
        ```swift
        .package(url: "https://github.com/marek.fort/TestPackage.git", .upToNextMajor(from: "0.0.1")),
        ```

        ```ruby
        pod "TestPackage", "~> 1.0.0"
        pod "Random", "~> 0.0.1"
        ```
        """
        XCTAssertEqual(try fileHandler.readTextFile(readmePath), expectedContent)
    }
}
