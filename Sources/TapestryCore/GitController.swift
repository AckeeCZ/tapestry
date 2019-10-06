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
    func commit(_ message: String) throws
    func tagVersion(_ version: Version) throws
}

/// Class for interacting with git
public final class GitController: GitControlling {
    private let system: Systeming
    private let fileHandler: FileHandling
    
    public init(system: Systeming = System(), fileHandler: FileHandling = FileHandler()) {
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
    
    public func tagVersion(_ version: Version) throws {
        try system.run("git", "tag", version.description)
    }
    
    public func commit(_ message: String) throws {
        try system.run("git", "commit", "-m")
    }
}
