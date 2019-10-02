//
//  GitController.swift
//  
//
//  Created by Marek Fořt on 9/9/19.
//

import Foundation
import TuistCore
import Basic

public protocol GitControlling {
    func initGit(path: AbsolutePath) throws
    func currentName() throws -> String
    func currentEmail() throws -> String
}

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
}
