import Basic
import Foundation
import TuistGenerator
//import TuistLoader
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

//    /// Project editor mapper.
//    let projectEditorMapper: ProjectEditorMapping

//    /// Utility to locate Tuist's resources.
//    let resourceLocator: ResourceLocating

//    /// Utility to locate manifest files.
//    let manifestFilesLocator: ManifestFilesLocating

//    /// Utility to locate the helpers directory.
//    let helpersDirectoryLocator: HelpersDirectoryLocating

    init(configEditorGenerator: ConfigEditorGenerating = ConfigEditorGenerator()) {
        self.configEditorGenerator = configEditorGenerator
    }

    func edit(at: AbsolutePath, in dstDirectory: AbsolutePath) throws -> AbsolutePath {
        let xcodeprojPath = dstDirectory.appending(component: "Tapestry.xcodeproj")

//        let projectDesciptionPath = try resourceLocator.projectDescription()
        let projectDescriptionPath = at.appending(component: "TapestryConfig.swift")
//        let manifests = manifestFilesLocator.locate(at: at)
//        var helpers: [AbsolutePath] = []
//        if let helpersDirectory = helpersDirectoryLocator.locate(at: at) {
//            helpers = FileHandler.shared.glob(helpersDirectory, glob: "**/*.swift")
//        }

        // TODO: Error!
        /// We error if the user tries to edit a project in a directory where there are no editable files.
//        if manifests.isEmpty, helpers.isEmpty {
//            throw ProjectEditorError.noEditableFiles(at)
//        }
        
        return try configEditorGenerator.generateProject(path: xcodeprojPath)
    }
}
