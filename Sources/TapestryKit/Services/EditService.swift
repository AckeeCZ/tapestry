import Foundation
import Signals
import TSCBasic
import TapestryCore

final class EditService {
    private let projectEditor: ProjectEditing
    private let opener: Opening
    
    init(
        projectEditor: ProjectEditing = ProjectEditor(),
        opener: Opening = Opener()
    ) {
        self.projectEditor = projectEditor
        self.opener = opener
    }
    
    func run(
        path: String?,
        permanent: Bool
    ) throws {
        let path = self.path(path)

        if !permanent {
            try withTemporaryDirectory { generationDirectory in
                EditService.temporaryDirectory = generationDirectory

                Signals.trap(signals: [.int, .abrt]) { _ in
                    // swiftlint:disable:next force_try
                    try! EditService.temporaryDirectory.map(FileHandler.shared.delete)
                    exit(0)
                }

                let xcodeprojPath = try projectEditor.edit(at: path, in: generationDirectory)
                Printer.shared.print(success: "Opening Xcode to edit the project. Press CTRL + C once you are done editing")
                try opener.open(path: xcodeprojPath, wait: true)
            }
        } else {
            let xcodeprojPath = try projectEditor.edit(at: path, in: path)
            Printer.shared.print(success: "Xcode project generated at \(xcodeprojPath.pathString)")
        }
    }
    
    // MARK: - Helpers

    private func path(_ path: String?) -> AbsolutePath {
        if let path = path {
            return AbsolutePath(path, relativeTo: FileHandler.shared.currentPath)
        } else {
            return FileHandler.shared.currentPath
        }
    }

    private static var temporaryDirectory: AbsolutePath?
}
