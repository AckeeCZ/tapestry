import TSCBasic
import TapestryKit
import TapestryGen

class MockConfigModelLoader: ConfigModelLoading {
    var loadTapestryConfigStub: ((AbsolutePath) throws -> TapestryConfig)?
    
    func loadTapestryConfig(at path: AbsolutePath) throws -> TapestryConfig {
        try loadTapestryConfigStub?(path) ?? .test()
    }
}

extension TapestryConfig {
    static func test(release: Release = .test()) -> TapestryConfig {
        return TapestryConfig(release: release)
    }
}

extension Release {
    static func test(actions: [ReleaseAction] = [],
                     add: [String] = ["README.md"],
                     commitMessage: String = "Version \(Argument.version.rawValue)",
                     push: Bool = false) -> Release {
        return Release(actions: actions,
                       add: add,
                       commitMessage: commitMessage,
                       push: push)
    }
}

