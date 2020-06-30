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
        let generationDirectory = permanent ? path : EditService.temporaryDirectory.path
        let xcodeprojPath = try projectEditor.edit(at: path, in: generationDirectory)

        if !permanent {
            Signals.trap(signals: [.int, .abrt]) { _ in
                // swiftlint:disable:next force_try
                try! FileHandler.shared.delete(EditService.temporaryDirectory.path)
                exit(0)
            }
            Printer.shared.print(success: "Opening Xcode to edit the project. Press CTRL + C once you are done editing")
            try opener.open(path: xcodeprojPath, wait: true)
        } else {
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
    
    fileprivate static var _temporaryDirectory: TemporaryDirectory?
    fileprivate static var temporaryDirectory: TemporaryDirectory {
        // swiftlint:disable:next identifier_name
        if let _temporaryDirectory = _temporaryDirectory { return _temporaryDirectory }
        // swiftlint:disable:next force_try
        _temporaryDirectory = try! TemporaryDirectory(removeTreeOnDeinit: true)
        return _temporaryDirectory!
    }
}
