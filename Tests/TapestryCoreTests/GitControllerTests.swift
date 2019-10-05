import XCTest
import Basic
@testable import TapestryCore
@testable import TapestryCoreTesting

final class GitControllerTests: XCTestCase {
    private var subject: GitController!
    private var system: MockSystem!

    override func setUp() {
        super.setUp()
        system = MockSystem()
        subject = GitController(system: system,
                                fileHandler: try! MockFileHandler())
    }

    func test_init_git_succeeds() throws {
        let path = AbsolutePath("/test")
        system.succeedCommand(["git", "init", path.pathString])

        XCTAssertNoThrow(try subject.initGit(path: path))
    }

    func test_init_git_fails() throws {
        let path = AbsolutePath("/test")
        system.succeedCommand(["git", "init", "/fail"])

        XCTAssertThrowsError(try subject.initGit(path: path))
    }
    
    func test_currentName() throws {
        let name = "test"
        system.succeedCommand(["git", "config", "user.name"], output: name)
        XCTAssertEqual(try subject.currentName(), name)
    }
    
    func test_currentEmail() throws {
        let email = "test@test.com"
        system.succeedCommand(["git", "config", "user.email"], output: email)
        XCTAssertEqual(try subject.currentEmail(), email)
    }
}
