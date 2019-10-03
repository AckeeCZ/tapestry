//
//  InputReader.swift
//  TapestryGen
//
//  Created by Marek Fořt on 8/23/19.
//

import acho

private enum InputError: Error {
    case failedReading
}

public protocol InputReading {
    func readString(options: [String], question: String) throws -> String
    func readEnumInput<EnumType: RawRepresentable & CaseIterable>(question: String) throws -> EnumType where EnumType.RawValue == String
    func readRawInput<StringRawRepresentable: RawRepresentable, RawCollection: Collection>(options: RawCollection, question: String) throws -> StringRawRepresentable where StringRawRepresentable.RawValue == String, RawCollection.Element == StringRawRepresentable
}

public final class InputReader: InputReading {
    public init() {}
    
    public func readString(options: [String], question: String) throws -> String {
        let acho = Acho<String>()
        guard let answer = acho.ask(question: question, options: options) else { throw InputError.failedReading }
        return answer
    }

    public func readEnumInput<EnumType: RawRepresentable & CaseIterable>(question: String) throws -> EnumType where EnumType.RawValue == String {
        return try readRawInput(options: EnumType.allCases, question: question)
    }

    public func readRawInput<StringRawRepresentable: RawRepresentable, RawCollection: Collection>(options: RawCollection, question: String) throws -> StringRawRepresentable where StringRawRepresentable.RawValue == String, RawCollection.Element == StringRawRepresentable {
        let acho = Acho<String>()
        guard
            let answer = acho.ask(question: question, options: options.map { $0.rawValue }),
            let representedAnswer = StringRawRepresentable(rawValue: answer)
        else { throw InputError.failedReading }
        return representedAnswer
    }
}
