import SPMUtility
import TuistCore
import XCTest
@testable import TapestryCoreTesting
@testable import TapestryKit

final class InitCommandTests: XCTestCase {
    private var subject: InitCommand!
    private var parser: ArgumentParser!
    
    override func setUp() {
        super.setUp()
        parser = ArgumentParser.test()
        subject = InitCommand(parser: parser,
                              fileHandler: try! MockFileHandler(),
                              printer: MockPrinter(),
                              exampleGenerator: MockExampleGenerator(),
                              gitController: MockGitController(),
                              system: MockSystem(),
                              packageGenerator: MockPackageGenerator())
    }
}

extension ArgumentParser {
    static func test(usage: String = "test",
                     overview: String = "overview") -> ArgumentParser {
        return ArgumentParser(usage: usage, overview: overview)
    }
}

