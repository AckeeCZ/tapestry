import XCTest
import Basic
import SPMUtility
import TapestryCore
@testable import TapestryCoreTesting
@testable import TapestryKit

final class EditCommandTests: TapestryUnitTestCase {
    private var subject: EditCommand!
    private var parser: ArgumentParser!
    
    override func setUp() {
        super.setUp()
        parser = ArgumentParser.test()
        subject = EditCommand(parser: parser)
    }
}
