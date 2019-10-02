import Basic
import Foundation
import TapestryCore

public final class MockPrinter: Printing {
    public func print(_ text: String, includeNewline: Bool) {}
    
    public func print(_ text: String, output: PrinterOutput, includeNewline: Bool) {}
    
    public func print(_ text: String, color: TerminalController.Color) {}
    
    public func print(section: String) {}
    
    public func print(subsection: String) {}
    
    public func print(warning: String) {}
    
    public func print(error: Error) {}
    
    public func print(success: String) {}
    
    public func print(errorMessage: String) {}
    
    public func print(deprecation: String) {}
}
