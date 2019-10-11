import Foundation
import XCTest
import TuistCore
import TapestryCore

public class TapestryUnitTestCase: TapestryTestCase {
    public var system: MockSystem!
    public var fileHandler: MockFileHandler!

    public override func setUp() {
        super.setUp()
        // System
        system = MockSystem()
        System.shared = system

        // File handler
        // swiftlint:disable force_try
        fileHandler = try! MockFileHandler()
        FileHandler.shared = fileHandler
    }

    public override func tearDown() {
        // Printer
        printer = nil
        TapestryCore.Printer.shared = TapestryCore.Printer()

        // File handler
        fileHandler = nil
        TapestryCore.FileHandler.shared = TapestryCore.FileHandler()

        super.tearDown()
    }
}
