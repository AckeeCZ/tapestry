import XCTest
import TSCBasic
import TuistGenerator
@testable import TapestryCoreTesting
@testable import TapestryGen

final class ExampleModelLoaderTests: TapestryUnitTestCase {
    func test_loadProject() throws {
//        // Given
//        let packageName = "testPackage"
//        let name = "testName"
//        let bundleId = "testBundleId"
//        let path = AbsolutePath("/test")
//        let subject = ExampleModelLoader(packageName: packageName, name: name, bundleId: bundleId)
//        
//        // When
//        let project = try subject.loadProject(at: path)
//        
//        // Then
//        XCTAssertEqual(project.name, name)
//        XCTAssertEqual(project.targets.first?.filesGroup, .group(name: name))
//        XCTAssertEqual(project.targets.first?.bundleId, bundleId)
        // TODO: Bring back when https://bugs.swift.org/browse/SR-11501 is reolved
//        let dependency = try XCTUnwrap(project.targets.first?.dependencies.first)
//        switch dependency {
//        case let .package(package):
//            switch package {
//            case let .local(path: localPackagePath, productName: productName):
//                XCTAssertEqual(localPackagePath, RelativePath("../../\(packageName)"))
//                XCTAssertEqual(productName, packageName)
//            default:
//                XCTFail()
//            }
//        default:
//            XCTFail()
//        }
    }
}
