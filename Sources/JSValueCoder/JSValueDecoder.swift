//
//  JSValueDecoder.swift
//
//
//  Created by Theodore Lampert on 13.05.23.
//

import Foundation
import JavaScriptCore

extension JSValueDecoder {
    final class Decoder {
        let value: JSValue
        let keyDecodingStrategy: KeyDecodingStrategy

        var codingPath: [CodingKey]
        let userInfo: [CodingUserInfoKey: Any]

        convenience init(
            value: JSValue,
            keyDecodingStrategy: KeyDecodingStrategy,
            userInfo: [CodingUserInfoKey: Any]
        ) {
            self.init(
                value: value,
                keyDecodingStrategy: keyDecodingStrategy,
                codingPath: [],
                userInfo: userInfo
            )
        }

        convenience init(parent: Decoder, key: CodingKey) {
            self.init(parent: parent, value: parent.value, key: key)
        }

        convenience init(parent: Decoder, value: JSValue, key: CodingKey) {
            self.init(
                value: value,
                keyDecodingStrategy: parent.keyDecodingStrategy,
                codingPath: parent.codingPath + [key],
                userInfo: parent.userInfo
            )
        }

        private init(
            value: JSValue,
            keyDecodingStrategy: KeyDecodingStrategy,
            codingPath: [CodingKey],
            userInfo: [CodingUserInfoKey: Any]
        ) {
            self.value = value
            self.keyDecodingStrategy = keyDecodingStrategy
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension JSValueDecoder.Decoder: Decoder {
    func container<Key>(keyedBy _: Key.Type) -> KeyedDecodingContainer<Key> where Key: CodingKey {
        return KeyedDecodingContainer(JSValueDecoder.KeyedDecodingContainer(self))
    }

    func unkeyedContainer() -> UnkeyedDecodingContainer {
        return JSValueDecoder.UnkeyedDecodingContainer(self)
    }

    func singleValueContainer() -> SingleValueDecodingContainer {
        return JSValueDecoder.SingleValueDecodingContainer(self)
    }

    func decodedKey(_ codingKey: CodingKey) -> CodingKey {
        switch keyDecodingStrategy {
        case .useDefaultKeys:
            return codingKey
        case .convertFromSnakeCase:
            return JSValueCodingKey(convertingFromSnakeCase: codingKey)
        case let .custom(block):
            return block(codingPath + [codingKey])
        @unknown default:
            fatalError("\(keyDecodingStrategy) is not supported")
        }
    }
}

extension JSValueDecoder {
    struct KeyedDecodingContainer<Key>: KeyedDecodingContainerProtocol where Key: CodingKey {
        var allKeys: [Key] {
            return value
                .toDictionary()!
                .keys
                .compactMap { ($0 as? String).flatMap(Key.init) }
        }

        var codingPath: [CodingKey] {
            return decoder.codingPath
        }

        private var value: JSValue {
            return decoder.value
        }

        private let decoder: Decoder

        init(_ decoder: Decoder) {
            self.decoder = decoder
        }

        func contains(_ key: Key) -> Bool {
            return value.hasProperty(decoder.decodedKey(key).stringValue)
        }

        func decodeNil(forKey key: Key) -> Bool {
            return decodeValue(forKey: key).isNull
        }

        func decode(_: Bool.Type, forKey key: Key) -> Bool {
            return decodeValue(forKey: key).toBool()
        }

        func decode(_: String.Type, forKey key: Key) -> String {
            return decodeValue(forKey: key).toString()
        }

        func decode(_: Double.Type, forKey key: Key) -> Double {
            return decodeValue(forKey: key).toDouble()
        }

        func decode(_: Int32.Type, forKey key: Key) -> Int32 {
            return decodeValue(forKey: key).toInt32()
        }

        func decode(_: UInt32.Type, forKey key: Key) -> UInt32 {
            return decodeValue(forKey: key).toUInt32()
        }

        func decode(_: Float.Type, forKey key: Key) -> Float {
            return Float(decode(Double.self, forKey: key))
        }

        func decode(_: Int.Type, forKey key: Key) -> Int {
            return numericCast(decode(Int32.self, forKey: key))
        }

        func decode(_: Int8.Type, forKey key: Key) -> Int8 {
            return numericCast(decode(Int32.self, forKey: key))
        }

        func decode(_: Int16.Type, forKey key: Key) -> Int16 {
            return numericCast(decode(Int32.self, forKey: key))
        }

        func decode(_: Int64.Type, forKey key: Key) -> Int64 {
            return numericCast(decode(Int32.self, forKey: key))
        }

        func decode(_: UInt.Type, forKey key: Key) -> UInt {
            return numericCast(decode(UInt32.self, forKey: key))
        }

        func decode(_: UInt8.Type, forKey key: Key) -> UInt8 {
            return numericCast(decode(UInt32.self, forKey: key))
        }

        func decode(_: UInt16.Type, forKey key: Key) -> UInt16 {
            return numericCast(decode(UInt32.self, forKey: key))
        }

        func decode(_: UInt64.Type, forKey key: Key) -> UInt64 {
            return numericCast(decode(UInt32.self, forKey: key))
        }

        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
            if type == Date.self {
                return unsafeBitCast(decodeValue(forKey: key).toDate()!, to: T.self)
            }
            
            let decoder = Decoder(
                parent: decoder, value: decodeValue(forKey: key), key: key
            )

            return try type.init(from: decoder)
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) -> Swift
            .KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey
        {
            return Decoder(
                parent: decoder,
                value: decodeValue(forKey: key),
                key: key
            ).container(keyedBy: type)
        }

        func nestedUnkeyedContainer(forKey key: Key) -> Swift.UnkeyedDecodingContainer {
            return Decoder(
                parent: decoder,
                value: decodeValue(forKey: key),
                key: key
            ).unkeyedContainer()
        }

        func superDecoder() -> Swift.Decoder {
            return Decoder(parent: decoder, key: JSValueCodingKey.super)
        }

        func superDecoder(forKey key: Key) -> Swift.Decoder {
            return Decoder(parent: decoder, key: key)
        }

        private func decodeValue(forKey key: Key) -> JSValue {
            return value.forProperty(
                decoder.decodedKey(key).stringValue
            )
        }
    }
}

private extension JSValueDecoder {
    struct UnkeyedDecodingContainer: Swift.UnkeyedDecodingContainer {
        var codingPath: [CodingKey] {
            return decoder.codingPath
        }

        var count: Int? {
            return Int(value.forProperty("length").toInt32())
        }

        var isAtEnd: Bool {
            return currentIndex >= count!
        }

        private(set) var currentIndex: Int = 0

        private var value: JSValue {
            return decoder.value
        }

        private var currentKey: CodingKey {
            return JSValueCodingKey(intValue: currentIndex)
        }

        private let decoder: Decoder

        init(_ decoder: Decoder) {
            self.decoder = decoder
        }

        mutating func decodeNil() -> Bool {
            return decodeNext().isNull
        }

        mutating func decode(_: Bool.Type) -> Bool {
            return decodeNext().toBool()
        }

        mutating func decode(_: String.Type) -> String {
            return decodeNext().toString()
        }

        mutating func decode(_: Double.Type) -> Double {
            return decodeNext().toDouble()
        }

        mutating func decode(_: Int32.Type) -> Int32 {
            return decodeNext().toInt32()
        }

        mutating func decode(_: UInt32.Type) -> UInt32 {
            return decodeNext().toUInt32()
        }

        mutating func decode(_: Float.Type) -> Float {
            return Float(decode(Double.self))
        }

        mutating func decode(_: Int.Type) -> Int {
            return numericCast(decode(Int32.self))
        }

        mutating func decode(_: Int8.Type) -> Int8 {
            return numericCast(decode(Int32.self))
        }

        mutating func decode(_: Int16.Type) -> Int16 {
            return numericCast(decode(Int32.self))
        }

        mutating func decode(_: Int64.Type) -> Int64 {
            return numericCast(decode(Int32.self))
        }

        mutating func decode(_: UInt.Type) -> UInt {
            return numericCast(decode(UInt32.self))
        }

        mutating func decode(_: UInt8.Type) -> UInt8 {
            return numericCast(decode(UInt32.self))
        }

        mutating func decode(_: UInt16.Type) -> UInt16 {
            return numericCast(decode(UInt32.self))
        }

        mutating func decode(_: UInt64.Type) -> UInt64 {
            return numericCast(decode(UInt32.self))
        }

        mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
            if type == Date.self {
                return unsafeBitCast(decodeNext().toDate()!, to: T.self)
            }
            
            let decoder = Decoder(
                value: decodeNext(),
                keyDecodingStrategy: decoder.keyDecodingStrategy,
                userInfo: decoder.userInfo
            )

            return try type.init(from: decoder)
        }

        mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> Swift
            .KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey
        {
            let key = currentKey, value = decodeNext()
            return Decoder(parent: decoder, value: value, key: key).container(keyedBy: type)
        }

        mutating func nestedUnkeyedContainer() throws -> Swift.UnkeyedDecodingContainer {
            let key = currentKey, value = decodeNext()
            return Decoder(parent: decoder, value: value, key: key).unkeyedContainer()
        }

        func superDecoder() throws -> Swift.Decoder {
            return Decoder(parent: decoder, key: JSValueCodingKey.super)
        }

        private mutating func decodeNext() -> JSValue {
            defer { self.currentIndex += 1 }
            return value.atIndex(currentIndex)
        }
    }
}

private extension JSValueDecoder {
    struct SingleValueDecodingContainer: Swift.SingleValueDecodingContainer {
        var codingPath: [CodingKey] {
            return decoder.codingPath
        }

        private var value: JSValue {
            return decoder.value
        }

        private let decoder: Decoder

        init(_ decoder: Decoder) {
            self.decoder = decoder
        }

        func decodeNil() -> Bool {
            return value.isNull
        }

        func decode(_: Bool.Type) -> Bool {
            return value.toBool()
        }

        func decode(_: String.Type) -> String {
            return value.toString()
        }

        func decode(_: Double.Type) -> Double {
            return value.toDouble()
        }

        func decode(_: Int32.Type) -> Int32 {
            return value.toInt32()
        }

        func decode(_: UInt32.Type) -> UInt32 {
            return value.toUInt32()
        }

        func decode(_: Float.Type) -> Float {
            return Float(decode(Double.self))
        }

        func decode(_: Int.Type) -> Int {
            return numericCast(decode(Int32.self))
        }

        func decode(_: Int8.Type) -> Int8 {
            return numericCast(decode(Int32.self))
        }

        func decode(_: Int16.Type) -> Int16 {
            return numericCast(decode(Int32.self))
        }

        func decode(_: Int64.Type) -> Int64 {
            return numericCast(decode(Int32.self))
        }

        func decode(_: UInt.Type) -> UInt {
            return numericCast(decode(UInt32.self))
        }

        func decode(_: UInt8.Type) -> UInt8 {
            return numericCast(decode(UInt32.self))
        }

        func decode(_: UInt16.Type) -> UInt16 {
            return numericCast(decode(UInt32.self))
        }

        func decode(_: UInt64.Type) -> UInt64 {
            return numericCast(decode(UInt32.self))
        }

        func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
            if type == Date.self {
                return unsafeBitCast(value.toDate()!, to: T.self)
            }
            return try type.init(from: decoder)
        }
    }
}
