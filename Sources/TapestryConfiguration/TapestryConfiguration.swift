import TapestryCore

// MARK: - Project

public class TapestryConfiguration: Codable {
    public let release: ReleaseAction?

    public init(release: ReleaseAction? = nil) {
        self.release = release
    }
}

public class ReleaseAction: Codable {
    public let add: SourceFilesList?
    public let commitMessage: String?
    public let push: Bool
    
    public init(add: SourceFilesList? = nil,
                commitMessage: String? = nil,
                push: Bool = false) {
        self.add = add
        self.commitMessage = commitMessage
        self.push = push
    }
}

import func Foundation.NSTemporaryDirectory
import class Foundation.FileManager
import class Foundation.JSONDecoder
import class Foundation.JSONEncoder

extension TapestryConfiguration {
    public static func load() throws -> TapestryConfiguration {
        try Package.compile()
        
        let packageConfigJSON = NSTemporaryDirectory() + "TapestryConfiguration.json"

        guard let data = FileManager.default.contents(atPath: packageConfigJSON) else {
            fatalError("Fail")
//            throw Error("Could not find a file at \(packageConfigJSON) - something went wrong with compilation step probably")
        }

        return try JSONDecoder().decode(TapestryConfiguration.self, from: data)
    }
    
    public static func write(configuration: TapestryConfiguration) {
        let packageConfigJSON = NSTemporaryDirectory() + "TapestryConfiguration.json"
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(configuration)

            if !FileManager.default.createFile(atPath: packageConfigJSON, contents: data, attributes: nil) {
                Printer.shared.print(errorMessage: "PackageConfig: Could not create a temporary file for the PackageConfig: \(packageConfigJSON)")
            }
        } catch {
            Printer.shared.print(errorMessage: "Package config failed to encode configuration \(configuration)")
        }

        Printer.shared.print(success: "written to path: \(packageConfigJSON)")
    }
}
