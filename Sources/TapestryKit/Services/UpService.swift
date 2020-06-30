import Foundation
import TapestryCore
import TapestryGen
import TSCBasic

final class UpService {
    private let tapestryConfigGenerator: TapestryConfigGenerating
    
    init(
        tapestryConfigGenerator: TapestryConfigGenerating = TapestryConfigGenerator()
    ) {
        self.tapestryConfigGenerator = tapestryConfigGenerator
    }
    
    func run(
        path: String?
    ) throws {
        let path = self.path(path)
        
        Printer.shared.print("Generating tapestry config 🎨")
        
        try tapestryConfigGenerator.generateTapestryConfig(at: path)
        
        Printer.shared.print(success: "Generation succeeded! ✅")
    }
    
    private func path(_ path: String?) -> AbsolutePath {
        if let path = path {
            return AbsolutePath(path, relativeTo: FileHandler.shared.currentPath)
        } else {
            return FileHandler.shared.currentPath
        }
    }
}
