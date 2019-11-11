import Basic
import protocol TuistSupport.FatalError
import class TuistSupport.FileHandler
import enum TuistSupport.ErrorType
import Foundation
import TapestryCore

protocol ResourceLocating: AnyObject {
    func projectDescription(path: AbsolutePath) throws -> AbsolutePath
    func cliPath() throws -> AbsolutePath
}

enum ResourceLocatingError: FatalError {
    case notFound(String)

    var description: String {
        switch self {
        case let .notFound(name):
            return "Couldn't find \(name)"
        }
    }

    var type: ErrorType {
        switch self {
        default:
            return .bug
        }
    }

    static func == (lhs: ResourceLocatingError, rhs: ResourceLocatingError) -> Bool {
        switch (lhs, rhs) {
        case let (.notFound(lhsPath), .notFound(rhsPath)):
            return lhsPath == rhsPath
        }
    }
}

final class ResourceLocator: ResourceLocating {
    // MARK: - ResourceLocating

    func projectDescription(path: AbsolutePath) throws -> AbsolutePath {
        return try frameworkPath("PackageDescription", path: path)
    }

    func cliPath() throws -> AbsolutePath {
        return try toolPath("tuist")
    }

    // MARK: - Fileprivate

    private func frameworkPath(_ name: String, path: AbsolutePath) throws -> AbsolutePath {
        let pathComponents = path.pathString.components(separatedBy: "/")
        guard
            let tapestriesIndex = path.pathString.components(separatedBy: "/").firstIndex(where: { $0 == Constants.tapestriesName })
        else {
            throw ResourceLocatingError.notFound(name)
        }
        
        let tapestriesPath = AbsolutePath(pathComponents.prefix(through: tapestriesIndex).joined(separator: "/"))
        
        // TODO: Candidates
        let frameworkPath = tapestriesPath.appending(RelativePath(".build/debug/lib\(name).dylib"))
        guard FileHandler.shared.exists(frameworkPath) else {
            throw ResourceLocatingError.notFound(name)
        }
        return frameworkPath
    }

    private func toolPath(_ name: String) throws -> AbsolutePath {
        let bundlePath = AbsolutePath(Bundle(for: GraphManifestLoader.self).bundleURL.path)
        let paths = [bundlePath, bundlePath.parentDirectory]
        let candidates = paths.map { $0.appending(component: name) }
        guard let path = candidates.first(where: { FileHandler.shared.exists($0) }) else {
            throw ResourceLocatingError.notFound(name)
        }
        return path
    }
}
