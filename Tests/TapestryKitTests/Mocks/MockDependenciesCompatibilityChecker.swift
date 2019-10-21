import Basic
import TapestryGen
@testable import TapestryKit

final class MockDependenciesCompatibilityChecker: DependenciesCompatibilityChecking {
    var checkCompatibilityStub: (([ReleaseAction.DependenciesManager], AbsolutePath) throws -> ())?
    
    func checkCompatibility(with dependenciesManagers: [ReleaseAction.DependenciesManager], path: AbsolutePath) throws {
        try checkCompatibilityStub?(dependenciesManagers, path)
    }
}
