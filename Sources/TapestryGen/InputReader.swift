//
//  InputReader.swift
//  TapestryGen
//
//  Created by Marek Fořt on 8/23/19.
//

import acho

enum InputError: Error {
    case failedReading
}

protocol InputReading {
    func readString(options: [String], question: String) throws -> String
    func readEnumInput<EnumType: RawRepresentable & CaseIterable>(question: String) throws -> EnumType where EnumType.RawValue == String
    func readRawInput<StringRawRepresentable: RawRepresentable, RawCollection: Collection>(options: RawCollection, question: String) throws -> StringRawRepresentable where StringRawRepresentable.RawValue == String, RawCollection.Element == StringRawRepresentable
}

class InputReader: InputReading {
    func readString(options: [String], question: String) throws -> String {
        let acho = Acho<String>()
        guard let answer = acho.ask(question: question, options: options) else { throw InputError.failedReading }
        return answer
    }

    func readEnumInput<EnumType: RawRepresentable & CaseIterable>(question: String) throws -> EnumType where EnumType.RawValue == String {
        return try readRawInput(options: EnumType.allCases, question: question)
    }

    func readRawInput<StringRawRepresentable: RawRepresentable, RawCollection: Collection>(options: RawCollection, question: String) throws -> StringRawRepresentable where StringRawRepresentable.RawValue == String, RawCollection.Element == StringRawRepresentable {
        let acho = Acho<String>()
        guard
            let answer = acho.ask(question: question, options: options.map { $0.rawValue }),
            let representedAnswer = StringRawRepresentable(rawValue: answer)
        else { throw InputError.failedReading }
        return representedAnswer
    }
}
