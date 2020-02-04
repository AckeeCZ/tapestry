import Basic
import Foundation
import TapestryCore
import XCTest

@testable import TapestryCoreTesting
@testable import TapestryKit

final class ProjectEditorTests: TapestryUnitTestCase {
    var configEditorGenerator: MockConfigEditorGenerator!
    var resourceLocator: MockResourceLocator!
    var subject: ProjectEditor!

    override func setUp() {
        super.setUp()
        configEditorGenerator = MockConfigEditorGenerator()
        resourceLocator = MockResourceLocator()
        subject = ProjectEditor(configEditorGenerator: configEditorGenerator,
                                resourceLocator: resourceLocator)
    }

    override func tearDown() {
        super.tearDown()
        configEditorGenerator = nil
        resourceLocator = nil
        subject = nil
    }

    func test_edit_when_there_are_no_editable_files() throws {
        // Given
        let directory = try temporaryPath()
        let projectDescriptionPath = directory.appending(component: "ProjectDescription.framework")

        resourceLocator.projectDescriptionStub = { projectDescriptionPath }

        // When
        XCTAssertThrowsSpecific(try subject.edit(at: directory, in: directory), ProjectEditorError.noEditableFiles(directory))
    }
}
