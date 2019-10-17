import Basic
import Foundation
import PackageDescription
import protocol TuistCore.FatalError
import enum TuistCore.ErrorType
import TapestryCore
import class TuistCore.System

protocol ResourceLocating: AnyObject {
    func projectDescription() throws -> AbsolutePath
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

    func projectDescription() throws -> AbsolutePath {
        return try frameworkPath("ProjectDescription")
    }

    func cliPath() throws -> AbsolutePath {
        return try toolPath("tuist")
    }

    // MARK: - Fileprivate

    private func frameworkPath(_ name: String) throws -> AbsolutePath {
        let frameworkNames = ["\(name).framework", "lib\(name).dylib"]
        let bundlePath = AbsolutePath(Bundle(for: GraphManifestLoader.self).bundleURL.path)
        let paths = [
            bundlePath,
            bundlePath.parentDirectory,
        ]
        let candidates = paths.flatMap { path in
            frameworkNames.map { path.appending(component: $0) }
        }
        guard let frameworkPath = candidates.first(where: { FileHandler.shared.exists($0) }) else {
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


enum GraphManifestLoaderError: FatalError, Equatable {
    case projectDescriptionNotFound(AbsolutePath)
    case unexpectedOutput(AbsolutePath)
    case manifestNotFound(Manifest?, AbsolutePath)

    static func manifestNotFound(_ path: AbsolutePath) -> GraphManifestLoaderError {
        return .manifestNotFound(nil, path)
    }

    var description: String {
        switch self {
        case let .projectDescriptionNotFound(path):
            return "Couldn't find ProjectDescription.framework at path \(path.pathString)"
        case let .unexpectedOutput(path):
            return "Unexpected output trying to parse the manifest at path \(path.pathString)"
        case let .manifestNotFound(manifest, path):
            return "\(manifest?.fileName ?? "Manifest") not found at path \(path.pathString)"
        }
    }

    var type: ErrorType {
        switch self {
        case .unexpectedOutput:
            return .bug
        case .projectDescriptionNotFound:
            return .bug
        case .manifestNotFound:
            return .abort
        }
    }

    // MARK: - Equatable

    static func == (lhs: GraphManifestLoaderError, rhs: GraphManifestLoaderError) -> Bool {
        switch (lhs, rhs) {
        case let (.projectDescriptionNotFound(lhsPath), .projectDescriptionNotFound(rhsPath)):
            return lhsPath == rhsPath
        case let (.unexpectedOutput(lhsPath), .unexpectedOutput(rhsPath)):
            return lhsPath == rhsPath
        case let (.manifestNotFound(lhsManifest, lhsPath), .manifestNotFound(rhsManifest, rhsPath)):
            return lhsManifest == rhsManifest && lhsPath == rhsPath
        default:
            return false
        }
    }
}

enum Manifest: CaseIterable {
    case tapestryConfig

    var fileName: String {
        switch self {
        case .tapestryConfig:
            return "TapestryConfig.swift"
        }
    }
}

protocol GraphManifestLoading {
    /// Loads the TuistConfig.swift in the given directory.
    ///
    /// - Parameter path: Path to the directory that contains the TuistConfig.swift file.
    /// - Returns: Loaded TuistConfig.swift file.
    /// - Throws: An error if the file has a syntax error.
    func loadTapestryConfig(at path: AbsolutePath) throws -> PackageDescription.TapestryConfig

    func manifests(at path: AbsolutePath) -> Set<Manifest>
    func manifestPath(at path: AbsolutePath, manifest: Manifest) throws -> AbsolutePath
}

class GraphManifestLoader: GraphManifestLoading {
    // MARK: - Attributes

    /// Resource locator to look up Tuist-related resources.
    let resourceLocator: ResourceLocating

    /// A decoder instance for decoding the raw manifest data to their concrete types
    private let decoder: JSONDecoder

    // MARK: - Init

    /// Initializes the manifest loader with its attributes.
    ///
    /// - Parameters:
    ///   - resourceLocator: Resource locator to look up Tuist-related resources.
    init(resourceLocator: ResourceLocating = ResourceLocator()) {
        self.resourceLocator = resourceLocator
        decoder = JSONDecoder()
    }

    func manifestPath(at path: AbsolutePath, manifest: Manifest) throws -> AbsolutePath {
        let filePath = path.appending(component: manifest.fileName)

        if FileHandler.shared.exists(filePath) {
            return filePath
        } else {
            throw GraphManifestLoaderError.manifestNotFound(manifest, path)
        }
    }

    func manifests(at path: AbsolutePath) -> Set<Manifest> {
        return .init(Manifest.allCases.filter {
            FileHandler.shared.exists(path.appending(component: $0.fileName))
        })
    }

    /// Loads the TuistConfig.swift in the given directory.
    ///
    /// - Parameter path: Path to the directory that contains the TuistConfig.swift file.
    /// - Returns: Loaded TuistConfig.swift file.
    /// - Throws: An error if the file has a syntax error.
    func loadTapestryConfig(at path: AbsolutePath) throws -> PackageDescription.TapestryConfig {
        return try loadManifest(.tapestryConfig, at: path)
    }

    // MARK: - Private

    private func loadManifest<T: Decodable>(_ manifest: Manifest, at path: AbsolutePath) throws -> T {
        let manifestPath = path.appending(component: manifest.fileName)
        guard FileHandler.shared.exists(manifestPath) else {
            throw GraphManifestLoaderError.manifestNotFound(manifest, path)
        }
        let data = try loadManifestData(at: manifestPath)
        return try decoder.decode(T.self, from: data)
    }

    private func loadManifestData(at path: AbsolutePath) throws -> Data {
        let projectDescriptionPath = try resourceLocator.projectDescription()
        var arguments: [String] = [
            "/usr/bin/xcrun",
            "swiftc",
            "--driver-mode=swift",
            "-suppress-warnings",
            "-I", projectDescriptionPath.parentDirectory.pathString,
            "-L", projectDescriptionPath.parentDirectory.pathString,
            "-F", projectDescriptionPath.parentDirectory.pathString,
            "-lProjectDescription",
        ]
        arguments.append(path.pathString)
        arguments.append("--dump")

        guard let jsonString = try System.shared.capture(arguments).spm_chuzzle(),
            let data = jsonString.data(using: .utf8) else {
            throw GraphManifestLoaderError.unexpectedOutput(path)
        }

        return data
    }
}
