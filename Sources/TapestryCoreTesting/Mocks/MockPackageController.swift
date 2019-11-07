import Basic
import TapestryCore

public final class MockPackageController: PackageControlling {
    public var initPackageStub: ((AbsolutePath, String) throws -> PackageType)?
    public var generateXcodeprojStub: ((AbsolutePath, AbsolutePath?) throws -> ())?
    public var runStub: ((String, [String], AbsolutePath) throws -> ())?
    public var nameStub: ((AbsolutePath) throws -> String)?
    public var updateStub: ((AbsolutePath) throws -> ())?
    
    public func initPackage(path: AbsolutePath, name: String) throws -> PackageType {
        try initPackageStub?(path, name) ?? .library
    }
    
    public func generateXcodeproj(path: AbsolutePath, output: AbsolutePath?) throws {
        try generateXcodeprojStub?(path, output)
    }
    
    public func run(_ tool: String, arguments: [String], path: AbsolutePath) throws {
        try runStub?(tool, arguments, path)
    }
    
    public func name(from path: AbsolutePath) throws -> String {
        try nameStub?(path) ?? ""
    }
    
    public func update(path: AbsolutePath) throws {
        try updateStub?(path)
    }
}
