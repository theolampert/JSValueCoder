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
        self.init(stringValue: String(convertingFromSnakeCase: other.stringValue))
    }
}

private extension String {
    init(convertingToSnakeCase string: String) {
        self.init(source: string) {
            var result = ContiguousArray<UTF16.CodeUnit>()
            result.reserveCapacity($0.count * 3 / 2)
            for scalar in string.unicodeScalars {
                if scalar.properties.isUppercase {
                    result.append(.underscore)
                    result.append(contentsOf: scalar.properties.lowercaseMapping.utf16)
                } else {
                    result.append(contentsOf: scalar.utf16)
                }
            }
            return result
        }
    }

    init(convertingFromSnakeCase string: String) {
        self.init(source: string) {
            var result = ContiguousArray<UTF16.CodeUnit>()
            result.reserveCapacity($0.count)
            var lastIdx = $0.startIndex
            while lastIdx < $0.endIndex, let underscoreIdx = $0[lastIdx...].firstIndex(of: .underscore) {
                result.append(contentsOf: $0[lastIdx ..< underscoreIdx])
                lastIdx = underscoreIdx + 1
                if lastIdx < $0.endIndex {
                    var codec = UTF16(), nextCharIterator = $0.makeIterator(at: lastIdx)
                    guard case let .scalarValue(decodedScalar) = codec.decode(&nextCharIterator) else {
                        continue
                    }
                    result.append(contentsOf: decodedScalar.properties.uppercaseMapping.utf16)
                    lastIdx = nextCharIterator.index
                }
            }
            if lastIdx < $0.endIndex {
                result.append(contentsOf: $0[lastIdx...])
            }
            return result
        }
    }

    private init(
        source string: String,
        transformingUTF16CodeUnitsUsing transform: (ContiguousArray<UTF16.CodeUnit>) -> ContiguousArray<UTF16.CodeUnit>
    ) {
        self = transform(ContiguousArray(string.utf16))
            .withUnsafeBufferPointer { String(utf16CodeUnits: $0.baseAddress!, count: $0.count) }
    }
}

private extension ContiguousArray where Element == UTF16.CodeUnit {
    struct RandomAccessIterator: IteratorProtocol {
        fileprivate private(set) var index: ContiguousArray.Index
        private let array: ContiguousArray

        fileprivate init(index: ContiguousArray.Index, in array: ContiguousArray) {
            self.array = array
            self.index = index
        }

        fileprivate mutating func next() -> UTF16.CodeUnit? {
            guard index < array.endIndex else {
                return nil
            }
            defer { self.index = self.array.index(after: self.index) }
            return array[index]
        }
    }

    func makeIterator(at index: Index) -> RandomAccessIterator {
        return RandomAccessIterator(index: index, in: self)
    }
}

private extension UTF16.CodeUnit {
    static let underscore = "_".utf16.first!
}
