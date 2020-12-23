import Foundation
import TSCBasic
import TSCUtility
import TapestryCore

final class GithubReleaseService {
    func run(
        path: String?,
        version: TSCUtility.Version
    ) throws {
        let path = self.path(path)
        
        try GitController.shared.tagVersion(version, path: path)
        
        try GitController.shared.pushTag(version.description, path: path)
        
        try GitController.shared.deleteTagVersion(version, path: path)
        
        Printer.shared.print(success: "Version will be uploaded via Github action")
    }
    
    // MARK: - Helpers
    
    private func path(_ path: String?) -> AbsolutePath {
        if let path = path {
            return AbsolutePath(path, relativeTo: FileHandler.shared.currentPath)
        } else {
            return FileHandler.shared.currentPath
        }
    }
}
