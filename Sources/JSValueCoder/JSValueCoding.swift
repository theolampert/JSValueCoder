//
//  JSValueCoding.swift
//
//
//  Created by Theodore Lampert on 13.05.23.
//

import Foundation
import JavaScriptCore

open class JSValueEncoder {
    public typealias KeyEncodingStrategy = JSONEncoder.KeyEncodingStrategy

    open var keyEncodingStrategy = KeyEncodingStrategy.useDefaultKeys
    open var userInfo = [CodingUserInfoKey: Any]()

    public init() {}

    open func encode<T>(
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

open class JSValueDecoder {
    public typealias KeyDecodingStrategy = JSONDecoder.KeyDecodingStrategy

    open var keyDecodingStrategy = KeyDecodingStrategy.useDefaultKeys
    open var userInfo = [CodingUserInfoKey: Any]()

    public init() {}

    open func decode<T>(
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
