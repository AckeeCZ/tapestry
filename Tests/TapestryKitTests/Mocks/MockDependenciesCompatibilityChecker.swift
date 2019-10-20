import Basic
import TapestryGen
@testable import TapestryKit

final class MockDependenciesCompatibilityChecker: DependenciesComptabilityChecking {
    var checkCompatibilityStub: (([ReleaseAction.DependendenciesManager], AbsolutePath) throws -> ())?
    
    func checkCompatibility(with dependenciesManagers: [ReleaseAction.DependendenciesManager], path: AbsolutePath) throws {
        try checkCompatibilityStub?(dependenciesManagers, path)
    }
}
