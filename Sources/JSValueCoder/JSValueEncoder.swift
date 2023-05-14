//
//  File.swift
//
//
//  Created by Theodore Lampert on 13.05.23.
//

import Foundation
import JavaScriptCore

extension JSValueEncoder {
    final class Encoder {
        let context: JSContext
        let keyEncodingStrategy: KeyEncodingStrategy

        let codingPath: [CodingKey]
        let userInfo: [CodingUserInfoKey: Any]

        var result: JSValue {
            get {
                guard let result = resultStorage else {
                    fatalError(
                        "container <Key> (keyedBy type: Key.Type), unkeyedContainer () or singleValueContainer () was never called"
                    )
                }
                return result
            }
            set {
                guard resultStorage == nil else {
                    fatalError(
                        "container <Key> (keyedBy type: Key.Type), unkeyedContainer () or singleValueContainer () was already called earlier"
                    )
                }
                resultStorage = newValue
            }
        }

        private var resultStorage: JSValue?

        convenience init(
            context: JSContext,
            keyEncodingStrategy: KeyEncodingStrategy,
            userInfo: [CodingUserInfoKey: Any]
        ) {
            self.init(context: context, keyEncodingStrategy: keyEncodingStrategy, codingPath: [], userInfo: userInfo)
        }

        convenience init(parent: Encoder, key: CodingKey) {
            self.init(
                context: parent.context,
                keyEncodingStrategy: parent.keyEncodingStrategy,
                codingPath: parent.codingPath + [key],
                userInfo: parent.userInfo
            )
        }

        private init(
            context: JSContext,
            keyEncodingStrategy: KeyEncodingStrategy,
            codingPath: [CodingKey],
            userInfo: [CodingUserInfoKey: Any]
        ) {
            self.context = context
            self.keyEncodingStrategy = keyEncodingStrategy
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension JSValueEncoder.Encoder: Encoder {
    func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        if resultStorage == nil {
            result = JSValue(newObjectIn: context)
        }
        return KeyedEncodingContainer(JSValueEncoder.KeyedEncodingContainer(self))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        if resultStorage == nil {
            result = JSValue(newArrayIn: context)
        }
        return JSValueEncoder.UnkeyedEncodingContainer(self)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        return JSValueEncoder.SingleValueEncodingContainer(self)
    }

    func encodedKey(_ codingKey: CodingKey) -> CodingKey {
        switch keyEncodingStrategy {
        case .useDefaultKeys:
            return codingKey
        case .convertToSnakeCase:
            return JSValueCodingKey(convertingToSnakeCase: codingKey)
        case let .custom(block):
            return block(codingPath + [codingKey])
        @unknown default:
            fatalError("\(keyEncodingStrategy) is not supported")
        }
    }
}

extension JSValueEncoder {
    struct KeyedEncodingContainer<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {
        var codingPath: [CodingKey] {
            return encoder.codingPath
        }

        private let encoder: Encoder

        private var target: JSValue {
            return encoder.result
        }

        private var context: JSContext {
            return encoder.context
        }

        init(_ encoder: Encoder) {
            self.encoder = encoder
        }

        func encodeNil(forKey key: Key) {
            encode(JSValue(nullIn: context), forKey: key)
        }

        func encode(_ value: Bool, forKey key: Key) {
            encode(JSValue(bool: value, in: context), forKey: key)
        }

        func encode(_ value: String, forKey key: Key) {
            encode(JSValue(object: value, in: context), forKey: key)
        }

        func encode(_ value: Double, forKey key: Key) {
            encode(JSValue(double: value, in: context), forKey: key)
        }

        func encode(_ value: Int32, forKey key: Key) {
            encode(JSValue(int32: value, in: context), forKey: key)
        }

        func encode(_ value: UInt32, forKey key: Key) {
            encode(JSValue(uInt32: value, in: context), forKey: key)
        }

        func encode(_ value: Float, forKey key: Key) {
            encode(Double(value), forKey: key)
        }

        func encode(_ value: Int, forKey key: Key) {
            encode(Int32(value), forKey: key)
        }

        func encode(_ value: Int8, forKey key: Key) {
            encode(Int32(value), forKey: key)
        }

        func encode(_ value: Int16, forKey key: Key) {
            encode(Int32(value), forKey: key)
        }

        func encode(_ value: Int64, forKey key: Key) {
            encode(Int32(value), forKey: key)
        }

        func encode(_ value: UInt, forKey key: Key) {
            encode(UInt32(value), forKey: key)
        }

        func encode(_ value: UInt8, forKey key: Key) {
            encode(UInt32(value), forKey: key)
        }

        func encode(_ value: UInt16, forKey key: Key) {
            encode(UInt32(value), forKey: key)
        }

        func encode(_ value: UInt64, forKey key: Key) {
            encode(UInt32(value), forKey: key)
        }

        func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
            switch value {
            case let date as Date:
                encode(JSValue(object: date, in: context), forKey: key)
            case let value:
                let encoder = Encoder(parent: self.encoder, key: key)
                try value.encode(to: encoder)
                encode(encoder.result, forKey: key)
            }
        }

        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> Swift
            .KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
        {
            return Encoder(parent: encoder, key: key).container(keyedBy: keyType)
        }

        mutating func nestedUnkeyedContainer(forKey key: Key) -> Swift.UnkeyedEncodingContainer {
            return Encoder(parent: encoder, key: key).unkeyedContainer()
        }

        mutating func superEncoder() -> Swift.Encoder {
            return Encoder(parent: encoder, key: JSValueCodingKey.super)
        }

        mutating func superEncoder(forKey key: Key) -> Swift.Encoder {
            return Encoder(parent: encoder, key: key)
        }

        private func encode(_ jsValue: JSValue, forKey key: Key) {
            target.setValue(jsValue, forProperty: encoder.encodedKey(key).stringValue)
        }
    }
}

extension JSValueEncoder {
    struct UnkeyedEncodingContainer: Swift.UnkeyedEncodingContainer {
        var codingPath: [CodingKey] {
            return encoder.codingPath
        }

        var count: Int {
            return Int(target.forProperty("length").toInt32())
        }

        private var currentKey: CodingKey {
            return JSValueCodingKey(intValue: count)
        }

        private let encoder: Encoder

        private var target: JSValue {
            return encoder.result
        }

        private var context: JSContext {
            return encoder.context
        }

        init(_ encoder: Encoder) {
            self.encoder = encoder
        }

        func encodeNil() {
            encode(JSValue(nullIn: context))
        }

        func encode(_ value: Bool) {
            encode(JSValue(bool: value, in: context))
        }

        func encode(_ value: String) {
            encode(JSValue(object: value, in: context))
        }

        func encode(_ value: Double) {
            encode(JSValue(double: value, in: context))
        }

        func encode(_ value: Int32) {
            encode(JSValue(int32: value, in: context))
        }

        func encode(_ value: UInt32) {
            encode(JSValue(uInt32: value, in: context))
        }

        func encode(_ value: Float) {
            encode(Double(value))
        }

        func encode(_ value: Int) {
            encode(Int32(value))
        }

        func encode(_ value: Int8) {
            encode(Int32(value))
        }

        func encode(_ value: Int16) {
            encode(Int32(value))
        }

        func encode(_ value: Int64) {
            encode(Int32(value))
        }

        func encode(_ value: UInt) {
            encode(UInt32(value))
        }

        func encode(_ value: UInt8) {
            encode(UInt32(value))
        }

        func encode(_ value: UInt16) {
            encode(UInt32(value))
        }

        func encode(_ value: UInt64) {
            encode(UInt32(value))
        }

        func encode<T>(_ value: T) throws where T: Encodable {
            switch value {
            case let date as Date:
                encode(JSValue(object: date, in: context))
            case let value:
                let encoder = Encoder(parent: self.encoder, key: currentKey)
                try value.encode(to: encoder)
                encode(encoder.result)
            }
        }

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> Swift
            .KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
        {
            return Encoder(parent: encoder, key: currentKey).container(keyedBy: keyType)
        }

        func nestedUnkeyedContainer() -> Swift.UnkeyedEncodingContainer {
            return Encoder(parent: encoder, key: currentKey).unkeyedContainer()
        }

        func superEncoder() -> Swift.Encoder {
            return Encoder(parent: encoder, key: JSValueCodingKey.super)
        }

        private func encode(_ jsValue: JSValue) {
            target.setValue(jsValue, at: count)
        }
    }
}

extension JSValueEncoder {
    struct SingleValueEncodingContainer: Swift.SingleValueEncodingContainer {
        var codingPath: [CodingKey] {
            return encoder.codingPath
        }

        private let encoder: Encoder

        private var context: JSContext {
            return encoder.context
        }

        init(_ encoder: Encoder) {
            self.encoder = encoder
        }

        func encodeNil() {
            encode(JSValue(nullIn: context))
        }

        func encode(_ value: Bool) {
            encode(JSValue(bool: value, in: context))
        }

        func encode(_ value: String) {
            encode(JSValue(object: value, in: context))
        }

        func encode(_ value: Double) {
            encode(JSValue(double: value, in: context))
        }

        func encode(_ value: Int32) {
            encode(JSValue(int32: value, in: context))
        }

        func encode(_ value: UInt32) {
            encode(JSValue(uInt32: value, in: context))
        }

        func encode(_ value: Float) {
            encode(Double(value))
        }

        func encode(_ value: Int) {
            encode(Int32(value))
        }

        func encode(_ value: Int8) {
            encode(Int32(value))
        }

        func encode(_ value: Int16) {
            encode(Int32(value))
        }

        func encode(_ value: Int64) {
            encode(Int32(value))
        }

        func encode(_ value: UInt) {
            encode(UInt32(value))
        }

        func encode(_ value: UInt8) {
            encode(UInt32(value))
        }

        func encode(_ value: UInt16) {
            encode(UInt32(value))
        }

        func encode(_ value: UInt64) {
            encode(UInt32(value))
        }

        func encode<T>(_ value: T) throws where T: Encodable {
            switch value {
            case let date as Date:
                encode(JSValue(object: date, in: context))
            case let value:
                try value.encode(to: encoder)
            }
        }

        private func encode(_ jsValue: JSValue) {
            encoder.result = jsValue
        }
    }
}
