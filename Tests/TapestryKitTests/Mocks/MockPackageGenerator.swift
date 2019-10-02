import TapestryGen
import Basic

final class MockPackageGenerator: PackageGenerating {
    var stubInitPackage: ((AbsolutePath, String) throws -> PackageType)?
    
    func initPackage(path: AbsolutePath, name: String) throws -> PackageType {
        try stubInitPackage?(path, name) ?? .library
    }
}
