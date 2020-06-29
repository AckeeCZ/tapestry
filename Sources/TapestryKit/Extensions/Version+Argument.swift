import TSCUtility

extension Version: ArgumentKind {
    public init(argument: String) throws {
        guard let version = Version(string: argument) else {
            throw ArgumentConversionError.typeMismatch(value: argument, expectedType: Int.self)
        }

        self = version
    }
    
    public static let completion: ShellCompletion = .none
}
