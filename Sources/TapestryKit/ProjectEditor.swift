import Basic
import Foundation
import TuistGenerator
import TapestryGen
import TuistSupport

enum ProjectEditorError: FatalError, Equatable {
    /// This error is thrown when we try to edit in a project in a directory that has no editable files.
    case noEditableFiles(AbsolutePath)

    var type: ErrorType {
        switch self {
        case .noEditableFiles: return .abort
        }
    }

    var description: String {
        switch self {
        case let .noEditableFiles(path):
            return "There are no editable files at \(path.pathString)"
        }
    }
}

protocol ProjectEditing: AnyObject {
    /// Generates an Xcode project to edit the Project defined in the given directory.
    /// - Parameters:
    ///   - at: Directory whose project will be edited.
    ///   - destinationDirectory: Directory in which the Xcode project will be generated.
    /// - Returns: The path to the generated Xcode project.
    func edit(at: AbsolutePath, in destinationDirectory: AbsolutePath) throws -> AbsolutePath
}

final class ProjectEditor: ProjectEditing {
    /// Project generator.
    private let configEditorGenerator: ConfigEditorGenerating
    
    /// Utility to locate Tapestry's resources
    private let resourceLocator: ResourceLocating

    init(configEditorGenerator: ConfigEditorGenerating = ConfigEditorGenerator(),
         resourceLocator: ResourceLocating = ResourceLocator()) {
        self.configEditorGenerator = configEditorGenerator
        self.resourceLocator = resourceLocator
    }

    func edit(at: AbsolutePath, in dstDirectory: AbsolutePath) throws -> AbsolutePath {
        let xcodeprojPath = dstDirectory.appending(component: "Tapestry.xcodeproj")

        let projectDesciptionPath = try resourceLocator.projectDescription()
        let projectDescriptionPath = at.appending(component: "TapestryConfig.swift")

        // TODO: Error!
        /// We error if the user tries to edit a project in a directory where there are no editable files.
//        if manifests.isEmpty, helpers.isEmpty {
//            throw ProjectEditorError.noEditableFiles(at)
//        }
        
        return try configEditorGenerator.generateProject(path: xcodeprojPath, rootPath: at, projectDescriptionPath: projectDesciptionPath)
    }
}
