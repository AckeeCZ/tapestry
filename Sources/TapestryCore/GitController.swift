//
//  GitController.swift
//  
//
//  Created by Marek Fořt on 9/9/19.
//

import Foundation
import TuistCore
import Basic
import SPMUtility

enum GitError: FatalError, Equatable {
    case tagExists(Version)
    
    var type: ErrorType { .abort }
    
    var description: String {
        switch self {
        case let .tagExists(version):
            return "Version tag \(version) already exists."
        }
    }
    
    static func == (lhs: GitError, rhs: GitError) -> Bool {
        switch (lhs, rhs) {
        case let (.tagExists(lhsVersion), .tagExists(rhsVersion)):
            return lhsVersion == rhsVersion
        }
    }
}

/// Interface for interacting with git
public protocol GitControlling {
    /// Initialize git repository
    /// - Parameters:
    ///     - path: Path defining where should the git repository be created
    func initGit(path: AbsolutePath) throws
    /// Get current git name
    /// - Returns: Git name
    func currentName() throws -> String
    /// Get current git email
    /// - Returns: Git email
    func currentEmail() throws -> String
    func commit(_ message: String, path: AbsolutePath?) throws
    func tagVersion(_ version: Version, path: AbsolutePath?) throws
    func tagExists(_ version: Version, path: AbsolutePath?) throws -> Bool
}

/// Class for interacting with git
public final class GitController: GitControlling {    
    private let system: Systeming
    private let fileHandler: FileHandling
    
    public init(system: Systeming = System(),
                fileHandler: FileHandling = FileHandler()) {
        self.system = system
        self.fileHandler = fileHandler
    }
    
    public func initGit(path: AbsolutePath) throws {
        try system.run("git", "init", path.pathString)
    }
    
    public func currentName() throws -> String {
        return try system.capture("git", "config", "user.name").replacingOccurrences(of: "\n", with: "")
    }
    
    public func currentEmail() throws -> String {
        return try system.capture("git", "config", "user.email").replacingOccurrences(of: "\n", with: "")
    }
    
    public func tagVersion(_ version: Version, path: AbsolutePath?) throws {
        guard try !tagExists(version, path: path) else { throw GitError.tagExists(version) }
        try fileHandler.inDirectory(path ?? fileHandler.currentPath) { [weak self] in
            try self?.system.run("git", "tag", version.description)
        }
    }
    
    public func commit(_ message: String, path: AbsolutePath?) throws {
        try fileHandler.inDirectory(path ?? fileHandler.currentPath) { [weak self] in
            try self?.system.run("git", "commit", "-am", message)
        }
    }
    
    public func tagExists(_ version: Version, path: AbsolutePath?) throws -> Bool {
        return try allTags(path: path).contains(version)
    }
    
    // MARK: - Helpers
    
    private func allTags(path: AbsolutePath?) throws -> [Version] {
        return try fileHandler.inDirectory(path ?? fileHandler.currentPath) { [weak self] in
            try self?.system.capture("git", "tag", "--list").split(separator: "\n").compactMap { Version(string: String($0)) } ?? []
        }
    }
}
