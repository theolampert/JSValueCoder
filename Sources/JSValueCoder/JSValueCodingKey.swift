//
//  JSValueCodingKey.swift
//
//
//  Created by Theodore Lampert on 13.05.23.
//

import Foundation

internal struct JSValueCodingKey: CodingKey {
    internal static let `super` = JSValueCodingKey(stringValue: "super")

    internal let stringValue: String
    internal let intValue: Int?

    internal init(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    internal init(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }

    internal init(convertingToSnakeCase other: CodingKey) {
        self.init(stringValue: String(convertingToSnakeCase: other.stringValue))
    }

    internal init(convertingFromSnakeCase other: CodingKey) {
        self.init(stringValue: String(convertingToSnakeCase: other.stringValue))
    }
}

private extension String {
    init(convertingToSnakeCase string: String) {
        let regex = try! NSRegularExpression(pattern: "([a-z])([A-Z])")
        let range = NSRange(location: 0, length: string.utf16.count)
        let snakeCase = regex.stringByReplacingMatches(
            in: string,
            options: [],
            range: range,
            withTemplate: "$1_$2").lowercased(
        )
        self.init(snakeCase)
    }
}
