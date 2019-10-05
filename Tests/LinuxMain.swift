import XCTest

import TapestryGenTests
import TapestryKitTests

var tests = [XCTestCaseEntry]()
tests += TapestryGenTests.__allTests()
tests += TapestryKitTests.__allTests()

XCTMain(tests)
