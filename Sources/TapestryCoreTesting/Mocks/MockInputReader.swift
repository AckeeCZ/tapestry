import TapestryCore

private enum InputReaderError: Error {
    case enumNotStubbed
}

public final class MockInputReader: InputReading {
    public var readStringStub: (([String], String) throws -> String)?
    public var readEnumInputStub: String?
    private var stubs: [String: String] = [:]
    
    public func promptCommand(_ text: String, output: String) {
        stubs[text] = output
    }
    
    public func readString(options: [String], question: String) throws -> String {
        return try readStringStub?(options, question) ?? ""
    }
    
    public func readEnumInput<EnumType>(question: String) throws -> EnumType where EnumType : CaseIterable, EnumType : RawRepresentable, EnumType.RawValue == String {
        guard
            let readEnumInputStub = readEnumInputStub,
            let enumValue = EnumType(rawValue: readEnumInputStub)
        else { return try defaultEnumValue() }
        return enumValue
    }
    
    public func prompt(_ text: String, defaultValue: String?) -> String {
        return stubs[text] ?? defaultValue ?? ""
    }
    
    // MARK: - Helpers
    
    private func defaultEnumValue<EnumType>() throws -> EnumType where EnumType : CaseIterable {
        guard let defaultEnumValue = EnumType.allCases.first else { throw InputReaderError.enumNotStubbed }
        return defaultEnumValue
    }
}
