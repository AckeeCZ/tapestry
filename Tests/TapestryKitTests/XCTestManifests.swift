#if !canImport(ObjectiveC)
import XCTest

extension InitCommandTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__InitCommandTests = [
        ("test_example_not_generated_when_executable", test_example_not_generated_when_executable),
        ("test_generateProject_when_library", test_generateProject_when_library),
        ("test_git_initialized", test_git_initialized),
        ("test_gitignore_is_generated", test_gitignore_is_generated),
        ("test_license_is_generated", test_license_is_generated),
        ("test_package_initialized_with_name_from_path", test_package_initialized_with_name_from_path),
        ("test_package_xcodeProj_is_generated", test_package_xcodeProj_is_generated),
        ("test_readme_is_generated", test_readme_is_generated),
        ("test_run_when_the_directory_is_not_empty", test_run_when_the_directory_is_not_empty),
        ("test_travis_is_generated_when_executable", test_travis_is_generated_when_executable),
        ("test_travis_is_generated_when_library", test_travis_is_generated_when_library),
    ]
}

public func __allTests() -> [TapestryUnitTestCaseEntry] {
    return [
        testCase(InitCommandTests.__allTests__InitCommandTests),
    ]
}
#endif
