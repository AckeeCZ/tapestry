import protocol TuistCore.FatalError
import enum TuistCore.ErrorType
import Basic
import TapestryCore
import Foundation

enum HookInstallerError: FatalError {
    case pathNotGitRepo(AbsolutePath)
    
    var description: String {
        switch self {
        case let .pathNotGitRepo(path):
            return "Path \(path.pathString) is not git repo"
        }
    }
    
    var type: ErrorType { .abort }
}

protocol HookInstalling {
    func installHooks(at path: AbsolutePath) throws
}

public final class HookInstaller: HookInstalling {
    /// The supported hooks for git
    private static let hookList = [
        "pre-commit",
        "prepare-commit-msg",
        "commit-msg",
        "post-commit",
        "pre-push",
    ]
    
    func installHooks(at path: AbsolutePath) throws {
        // Validate we're in a git repo
        guard try GitController.shared.isGitRepository(path: path) else {
            throw HookInstallerError.pathNotGitRepo(path)
        }
        
        let gitRootPath = try GitController.shared.gitDirectory(path: path)
        
        let hooksRootPath = gitRootPath.appending(component: "hooks")
        if !FileHandler.shared.exists(hooksRootPath) {
            try FileHandler.shared.createFolder(hooksRootPath)
        }

        // TODO: What if Package.swift isn't in the CWD?
        let swiftPackagePath = path.appending(component: "Package.swift")
        
//
//        // Copy in the komondor templates
//        try hookList.forEach { hookName in
//            var hookPath = URL(fileURLWithPath: hooksRoot.absoluteString)
//            hookPath.appendPathComponent(hookName)
//
//            // Separate header from script so we can
//            // update if the script updates
//            let header = renderScriptHeader(hookName)
//            let script = renderScript(hookName, swiftPackagePath)
//            let hook = header + script
//
//            // This is the same permissions that husky uses
//            let execAttribute: [FileAttributeKey: Any] = [
//                .posixPermissions: 0o755
//            ]
//
//            // Create it if it's not there
//            if !fileManager.fileExists(atPath: hookPath.path) {
//                logger.debug("Added the hook: \(hookName)")
//                fileManager.createFile(atPath: hookPath.path, contents: hook.data(using: .utf8), attributes: execAttribute)
//            } else {
//                // Check if the script part has had an update since last running install
//                let existingFileData = try Data(contentsOf: hookPath, options: [])
//                let content = String(data: existingFileData, encoding: .utf8)!
//
//                if content.contains(script) {
//                    logger.debug("Skipped the hook: \(hookName)")
//                } else {
//                    logger.debug("Updating the hook: \(hookName)")
//                    fileManager.createFile(atPath: hookPath.path, contents: hook.data(using: .utf8), attributes: execAttribute)
//                }
//            }
//        }
//        print("[Komondor] git-hooks installed")
    }
    
    private func renderScriptHeader() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let installDate = dateFormatter.string(from: Date())

        return
            """
            #!/bin/sh
            # Tapestry v\(Constants.version)
            # Installed: \(installDate)

            """
    }
    
    private func renderScript(_ hookName: String, _ swiftPackagePath: String) -> String {
        return
            """
            hookName=`basename "$0"`
            gitParams="$*"

            if grep -q \(hookName) \(swiftPackagePath); then
              # use prebuilt binary if one exists, preferring release
              builds=( '.build/release/komondor' '.build/debug/komondor' )
              for build in ${builds[@]} ; do
                if [[ -e $build ]] ; then
                  komondor=$build
                  break
                fi
              done
              # fall back to using 'swift run' if no prebuilt binary found
              komondor=${komondor:-'swift run komondor'}

              # run hook
              $tapestry hook \(hookName) $gitParams
            fi
            """
    }
}
