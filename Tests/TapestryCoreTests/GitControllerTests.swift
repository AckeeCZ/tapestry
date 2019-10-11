import XCTest
import Basic
import SPMUtility
import class TuistCore.System
@testable import TapestryCore
@testable import TapestryCoreTesting

final class GitControllerTests: TapestryUnitTestCase {
    private var subject: GitController!

    override func setUp() {
        super.setUp()
        subject = GitController()
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
    
    func test_tag_with_path_succeeds() throws {
        // Given
        let path = AbsolutePath("/test")
        let version = Version(0, 0, 1)
        system.succeedCommand(["git", "tag", "--list"], output: "")
        system.succeedCommand(["git", "tag", version.description])
        
        // Then
        XCTAssertNoThrow(try subject.tagVersion(version, path: path))
    }
    
    func test_tag_error_when_tag_exists() throws {
        // Given
        let path = AbsolutePath("/test")
        let version = Version(0, 0, 1)
        system.succeedCommand(["git", "tag", "--list"], output: "1.0.0\n0.0.1\n")
        system.succeedCommand(["git", "tag", version.description])
        
        // Then
        XCTAssertThrowsSpecific(try subject.tagVersion(version, path: path), GitError.tagExists(version))
    }
    
    func test_commit_with_path_succeeds() throws {
        // Given
        let path = AbsolutePath("/test")
        let message = "Test commit"
        system.succeedCommand(["git", "commit", "-am", message])
        
        // Then
        XCTAssertNoThrow(try subject.commit(message, path: path))
    }
}
