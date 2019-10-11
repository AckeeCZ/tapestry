import XCTest

import TapestryCoreTests
import TapestryGenTests
import TapestryKitTests

var tests = [TapestryUnitTestCaseEntry]()
tests += TapestryCoreTests.__allTests()
tests += TapestryGenTests.__allTests()
tests += TapestryKitTests.__allTests()

XCTMain(tests)
