import XCTest
import Basic
@testable import TapestryCore
@testable import TapestryCoreTesting
@testable import TapestryGen

final class TapestriesGeneratorTests: TapestryUnitTestCase {
    var subject: TapestriesGenerator!
    
    override func setUp() {
        super.setUp()
        subject = TapestriesGenerator()
    }
    
    func test_generate_fails_when_directory_not_empty() throws {
        // Given
        let tapestriesPath = fileHandler.currentPath.appending(component: "Tapestries")
        try fileHandler.createFolder(tapestriesPath)
        
        // Then
        XCTAssertThrowsSpecific(try subject.generateTapestries(at: fileHandler.currentPath), TapestriesGeneratorError.tapestriesFolderExists(tapestriesPath))
    }
    
    func test_generate_tapestries_folder() throws {
        // When
        try subject.generateTapestries(at: fileHandler.currentPath)
        
        // Then
        XCTAssertTrue(fileHandler.isFolder(fileHandler.currentPath.appending(component: "Tapestries")))
    }
    
    func test_generate_packageManifest() throws {
        // Given
        let packagePath = fileHandler.currentPath.appending(RelativePath("Tapestries/Package.swift"))
        
        let expectedContents = """
        // swift-tools-version:\(Constants.swiftVersion)
        // The swift-tools-version declares the minimum version of Swift required to build this package.

        import PackageDescription

        let package = Package(
            name: "Tapestries",
            products: [
            .library(name: "TapestryConfig", targets: ["TapestryConfig"])
            ],
            dependencies: [
                // Tapestry
                .package(url: "\(Constants.gitRepositoryURL)", .upToNextMajor(from: "\(Constants.version)")),
            ],
            targets: [
                .target(name: "TapestryConfig",
                        dependencies: [
                            "PackageDescription"
                ])
            ]
        )
        """
        
        // When
        try subject.generateTapestries(at: fileHandler.currentPath)
        
        // Then
        XCTAssertEqual(try fileHandler.readTextFile(packagePath), expectedContents)
    }
    
    func test_generate_tapestryConfig() throws {
        // Given
        packageController.nameStub = { _ in
            "TapestryDemo"
        }
        let tapestryConfigPath = fileHandler.currentPath.appending(RelativePath("Tapestries/Sources/TapestryConfig/TapestryConfig.swift"))
        let expectedContents = """
        import PackageDescription

        let config = TapestryConfig(release: Release(actions: [.pre(.docsUpdate),
                                                               .pre(.dependenciesCompatibility([.cocoapods, .carthage, .spm(.all)]))],
                                                     add: ["README.md",
                                                           "TapestryDemo.podspec",
                                                           "CHANGELOG.md"],
                                                     commitMessage: "Version \\(Argument.version)",
                                                     push: false))
        """
        
        // When
        try subject.generateTapestries(at: fileHandler.currentPath)
        
        // Then
        XCTAssertEqual(try fileHandler.readTextFile(tapestryConfigPath), expectedContents)
    }
}
