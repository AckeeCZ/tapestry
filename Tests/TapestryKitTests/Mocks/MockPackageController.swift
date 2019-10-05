import TapestryGen
import Basic

final class MockPackageController: PackageControlling {
    var initPackageStub: ((AbsolutePath, String) throws -> PackageType)?
    var generateXcodeprojStub: ((AbsolutePath) throws -> ())?
    
    func initPackage(path: AbsolutePath, name: String) throws -> PackageType {
        try initPackageStub?(path, name) ?? .library
    }
    
    func generateXcodeproj(path: AbsolutePath) throws {
        try generateXcodeprojStub?(path)
    }
}
