import Foundation
import XCTest
@testable import TapestryCore

public class TapestryUnitTestCase: TapestryTestCase {
    public var system: MockSystem!
    public var fileHandler: MockFileHandler!
    public var xcodeController: MockXcodeController!
    public var packageController: MockPackageController!
    public var inputReader: MockInputReader!
    public var gitController: MockGitController!

    public override func setUp() {
        super.setUp()
        // System
        system = MockSystem()
        System.shared = system

        // File handler
        // swiftlint:disable force_try
        fileHandler = try! MockFileHandler()
        FileHandler.shared = fileHandler
        
        // XcodeController
        xcodeController = MockXcodeController()
        XcodeController.shared = xcodeController
        
        // PackageController
        packageController = MockPackageController()
        PackageController.shared = packageController
        
        // InputReader
        inputReader = MockInputReader()
        InputReader.shared = inputReader
        
        // GitController
        gitController = MockGitController()
        GitController.shared = gitController
    }

    public override func tearDown() {
        // System
        system = nil
        System.shared = System()
        
        // Printer
        printer = nil
        Printer.shared = Printer()

        // File handler
        fileHandler = nil
        FileHandler.shared = FileHandler()
        
        
        // XcodeController
        xcodeController = nil
        XcodeController.shared = XcodeController()
        
        // PackageController
        packageController = nil
        PackageController.shared = PackageController()
        
        // InputReader
        inputReader = nil
        InputReader.shared = InputReader()
        
        // GitController
        gitController = nil
        GitController.shared = GitController()

        super.tearDown()
    }
}
