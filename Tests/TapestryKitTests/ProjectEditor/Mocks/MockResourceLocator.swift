import TSCBasic
import Foundation
@testable import TapestryKit

public final class MockResourceLocator: ResourceLocating {
    public var projectDescriptionCount: UInt = 0
    public var projectDescriptionStub: (() throws -> AbsolutePath)?

    public func projectDescription() throws -> AbsolutePath {
        projectDescriptionCount += 1
        return try projectDescriptionStub?() ?? AbsolutePath("/")
    }
}
