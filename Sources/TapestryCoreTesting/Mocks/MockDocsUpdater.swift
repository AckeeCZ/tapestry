import Basic
import SPMUtility
@testable import TapestryCore

final class MockDocsUpdater: DocsUpdating {
    var updateDocsStub: ((AbsolutePath, Version) throws -> ())?
    
    func updateDocs(path: AbsolutePath, version: Version) throws {
        try updateDocsStub?(path, version)
    }
}
