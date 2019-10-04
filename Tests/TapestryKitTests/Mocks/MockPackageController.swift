import TapestryGen
import Basic

final class MockPackageController: PackageControlling {
    var stubInitPackage: ((AbsolutePath, String) throws -> PackageType)?
    var stubGenerateXcodeproj: ((AbsolutePath) throws -> ())?
    
    func initPackage(path: AbsolutePath, name: String) throws -> PackageType {
        try stubInitPackage?(path, name) ?? .library
    }
    
    func generateXcodeproj(path: AbsolutePath) throws {
        try stubGenerateXcodeproj?(path)
    }
}
