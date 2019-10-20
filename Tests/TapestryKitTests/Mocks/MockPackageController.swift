import TapestryGen
import Basic

final class MockPackageController: PackageControlling {
    var initPackageStub: ((AbsolutePath, String) throws -> PackageType)?
    var generateXcodeprojStub: ((AbsolutePath) throws -> ())?
    var runStub: ((String, [String], AbsolutePath) throws -> ())?
    
    func initPackage(path: AbsolutePath, name: String) throws -> PackageType {
        try initPackageStub?(path, name) ?? .library
    }
    
    func generateXcodeproj(path: AbsolutePath) throws {
        try generateXcodeprojStub?(path)
    }
    
    func run(_ tool: String, arguments: [String], path: AbsolutePath) throws {
        try runStub?(tool, arguments, path)
    }
}
