//
//  GitController.swift
//  
//
//  Created by Marek Fořt on 9/9/19.
//

import Foundation
import Basic
import SPMUtility
import protocol TuistCore.FatalError
import enum TuistCore.ErrorType

enum GitError: FatalError, Equatable {
    case tagExists(Version)
    case gitDirectoryNotFound(AbsolutePath)
    
    var type: ErrorType { .abort }
    
    var description: String {
        switch self {
        case let .tagExists(version):
            return "Version tag \(version) already exists."
        case let .gitDirectoryNotFound(path):
            return "No git directory found at \(path.pathString)"
        }
    }
    
    static func == (lhs: GitError, rhs: GitError) -> Bool {
        switch (lhs, rhs) {
        case let (.tagExists(lhsVersion), .tagExists(rhsVersion)):
            return lhsVersion == rhsVersion
        case let (.gitDirectoryNotFound(lhsPath), .gitDirectoryNotFound(rhsPath)):
            return lhsPath == rhsPath
        default:
            return false
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
    /// Creates new commit and adds unstaged files
    /// - Parameters:
    ///     - message: Commit message
    ///     - path: Path of the git directory
    func commit(_ message: String, path: AbsolutePath?) throws
    /// Creates new tag
    /// - Parameters:
    ///     - version: New tag version
    ///     - path: Path of the git directory
    /// - Throws: When `version` already exists
    func tagVersion(_ version: Version, path: AbsolutePath?) throws
    /// Checks if tag version already exists
    /// - Parameters:
    ///     - version: Version to be checked
    ///     - path: Path of the git directory
    /// - Returns: True if `version` exists
    func tagExists(_ version: Version, path: AbsolutePath?) throws -> Bool
    /// Stages `files` for commit
    /// - Parameters:
    ///     - files: Files to stage
    ///     - path: Path of the git directory
    func add(files: [AbsolutePath], path: AbsolutePath?) throws
    /// Push to the remote repository
    /// - Parameters:
    ///     - path: Path of the git directory
    func push(path: AbsolutePath?) throws
    /// Push tags to the remote repository
        /// - Parameters:
    ///     - path: Path of the git directory
    func pushTags(path: AbsolutePath?) throws
    /// - Parameters:
    ///     - path: Path of the git directory
    /// - Returns: All tags for directory at `path`
    func allTags(path: AbsolutePath?) throws -> [Version]
    func isGitRepository(path: AbsolutePath) throws -> Bool
    func gitDirectory(path: AbsolutePath?) throws -> AbsolutePath
}

/// Class for interacting with git
public final class GitController: GitControlling {
    public static var shared: GitControlling = GitController()
    
    public func initGit(path: AbsolutePath) throws {
        try System.shared.run("git", "init", path.pathString)
    }
    
    public func currentName() throws -> String {
        return try System.shared.capture("git", "config", "user.name").replacingOccurrences(of: "\n", with: "")
    }
    
    public func currentEmail() throws -> String {
        return try System.shared.capture("git", "config", "user.email").replacingOccurrences(of: "\n", with: "")
    }
    
    public func tagVersion(_ version: Version, path: AbsolutePath?) throws {
        guard try !tagExists(version, path: path) else { throw GitError.tagExists(version) }
        try FileHandler.shared.inDirectory(path ?? FileHandler.shared.currentPath) {
            try System.shared.run("git", "tag", version.description)
        }
    }
    
    public func commit(_ message: String, path: AbsolutePath?) throws {
        try FileHandler.shared.inDirectory(path ?? FileHandler.shared.currentPath) {
            try System.shared.run("git", "commit", "-m", message)
        }
    }
    
    public func add(files: [AbsolutePath], path: AbsolutePath?) throws {
        try FileHandler.shared.inDirectory(path ?? FileHandler.shared.currentPath) {
            files.forEach {
                try? System.shared.run("git", "add", $0.pathString)
            }
        }
    }
    
    public func push(path: AbsolutePath?) throws {
        try FileHandler.shared.inDirectory(path ?? FileHandler.shared.currentPath) {
            try System.shared.run("git", "push")
        }
    }
    
    public func pushTags(path: AbsolutePath?) throws {
        try FileHandler.shared.inDirectory(path ?? FileHandler.shared.currentPath) {
            try System.shared.run("git", "push", "--tags")
        }
    }
    
    public func tagExists(_ version: Version, path: AbsolutePath?) throws -> Bool {
        return try allTags(path: path).contains(version)
    }
    
    public func allTags(path: AbsolutePath?) throws -> [Version] {
        return try FileHandler.shared.inDirectory(path ?? FileHandler.shared.currentPath) {
            try System.shared.capture("git", "tag", "--list").split(separator: "\n").compactMap { Version(string: String($0)) }
        }
    }
    
    public func isGitRepository(path: AbsolutePath) throws -> Bool {
        try FileHandler.shared.inDirectory(path) {
            do {
                try System.shared.run("git", "remote")
                return true
            } catch {
                return false
            }
        }
    }
    
    public func gitDirectory(path: AbsolutePath?) throws -> AbsolutePath {
        let runPath: AbsolutePath = path ?? FileHandler.shared.currentPath
        return try FileHandler.shared.inDirectory(runPath) {
            do {
                let gitDirectoryPath = try System.shared.capture("git", "rev-parse", "--git-dir")
                if gitDirectoryPath == ".git" {
                    return runPath.appending(component: ".git")
                } else {
                    return AbsolutePath(gitDirectoryPath)
                }
            } catch {
                throw GitError.gitDirectoryNotFound(path ?? FileHandler.shared.currentPath)
            }
        }
    }
}
