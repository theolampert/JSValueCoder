//
//  JSValueCoding.swift
//
//
//  Created by Theodore Lampert on 13.05.23.
//

import Foundation
import JavaScriptCore

public final class JSValueEncoder {
    public typealias KeyEncodingStrategy = JSONEncoder.KeyEncodingStrategy

    public var keyEncodingStrategy = KeyEncodingStrategy.useDefaultKeys
    public var userInfo = [CodingUserInfoKey: Any]()

    public init() {}

    public func encode<T>(
        _ value: T,
        in context: JSContext
    ) throws -> JSValue where T: Encodable {
        let encoder = Encoder(
            context: context,
            keyEncodingStrategy: keyEncodingStrategy,
            userInfo: userInfo
        )
        try value.encode(to: encoder)
        return encoder.result
    }
}

public final class JSValueDecoder {
    public typealias KeyDecodingStrategy = JSONDecoder.KeyDecodingStrategy

    public var keyDecodingStrategy = KeyDecodingStrategy.useDefaultKeys
    public var userInfo = [CodingUserInfoKey: Any]()

    public init() {}

    public func decode<T>(
        _ type: T.Type = T.self,
        from value: JSValue
    ) throws -> T where T: Decodable {
        let decoder = Decoder(
            value: value,
            keyDecodingStrategy: keyDecodingStrategy,
            userInfo: userInfo
        )
        return try type.init(from: decoder)
    }
}
