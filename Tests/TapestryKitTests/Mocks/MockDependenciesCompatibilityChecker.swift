import Basic
import TapestryGen
@testable import TapestryKit

final class MockDependenciesCompatibilityChecker: DependenciesComptabilityChecking {
    var checkCompatibilityStub: (([ReleaseAction.DependenciesManager], AbsolutePath) throws -> ())?
    
    func checkCompatibility(with dependenciesManagers: [ReleaseAction.DependenciesManager], path: AbsolutePath) throws {
        try checkCompatibilityStub?(dependenciesManagers, path)
    }
}
