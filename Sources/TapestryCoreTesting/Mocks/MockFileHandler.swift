import TSCBasic
import Foundation
import TapestryCore
import XCTest

public final class MockFileHandler: FileHandling {
    private let fileHandler: FileHandling
    private let currentDirectory: TemporaryDirectory

    public var currentPath: AbsolutePath {
        return currentDirectory.path
    }

    init() throws {
        currentDirectory = try TemporaryDirectory(removeTreeOnDeinit: true)
        fileHandler = FileHandler()
    }

    public func replace(_ to: AbsolutePath, with: AbsolutePath) throws {
        try fileHandler.replace(to, with: with)
    }

    public func inTemporaryDirectory(_ closure: (AbsolutePath) throws -> Void) throws {
        try closure(currentPath)
    }
    
    public func inDirectory<T>(_ directory: AbsolutePath, closure: () throws -> T) throws -> T {
        return try closure()
    }

    public func exists(_ path: AbsolutePath) -> Bool {
        return fileHandler.exists(path)
    }

    public func glob(_ path: AbsolutePath, glob: String) -> [AbsolutePath] {
        return fileHandler.glob(path, glob: glob)
    }

    public func createFolder(_ path: AbsolutePath) throws {
        try fileHandler.createFolder(path)
    }

    public func linkFile(atPath: AbsolutePath, toPath: AbsolutePath) throws {
        try fileHandler.linkFile(atPath: atPath, toPath: toPath)
    }

    public func move(from: AbsolutePath, to: AbsolutePath) throws {
        try fileHandler.move(from: from, to: to)
    }

    public func copy(from: AbsolutePath, to: AbsolutePath) throws {
        try fileHandler.copy(from: from, to: to)
    }

    public func delete(_ path: AbsolutePath) throws {
        try fileHandler.delete(path)
    }

    public func touch(_ path: AbsolutePath) throws {
        try fileHandler.touch(path)
    }

    public func readFile(_ at: AbsolutePath) throws -> Data {
        try fileHandler.readFile(at)
    }
    
    public func readTextFile(_ at: AbsolutePath) throws -> String {
        return try fileHandler.readTextFile(at)
    }

    public func isFolder(_ path: AbsolutePath) -> Bool {
        return fileHandler.isFolder(path)
    }

    public func write(_ content: String, path: AbsolutePath, atomically: Bool) throws {
        return try fileHandler.write(content, path: path, atomically: atomically)
    }
}

extension MockFileHandler {
    @discardableResult
    func createFiles(_ files: [String]) throws -> [AbsolutePath] {
        let paths = files.map { currentPath.appending(RelativePath($0)) }
        try paths.forEach {
            try touch($0)
        }
        return paths
    }

    @discardableResult
    func createFolders(_ folders: [String]) throws -> [AbsolutePath] {
        let paths = folders.map { currentPath.appending(RelativePath($0)) }
        try paths.forEach {
            try createFolder($0)
        }
        return paths
    }
}
