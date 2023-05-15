import XCTest
import JavaScriptCore
@testable import JSValueCoder

final class JSValueCoderTests: XCTestCase {
    
    private func assertDecoderSucceeds<T: Codable & Equatable>(
        type: T.Type,
        value: T,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let context = JSContext()!
        let encoder = JSValueEncoder()
        let decoder = JSValueDecoder()

        let encoded: JSValue = try encoder.encode(value, in: context)
        let decoded: T = try decoder.decode(type, from: encoded)
        XCTAssertEqual(
            decoded,
            value,
            file: file,
            line: line
        )
    }
    
    func testKeyedString() throws {
        struct Value: Codable, Equatable {
            let string: String
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                string: "Hello"
            )
        )
    }
    
    func testKeyedBool() throws {
        struct Value: Codable, Equatable {
            let bool: Bool
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                bool: false
            )
        )
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                bool: true
            )
        )
    }
    
    func testKeyedDouble() throws {
        struct Value: Codable, Equatable {
            let double: Double
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                double: 3.8
            )
        )
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                double: -943.9
            )
        )
    }
    
    func testKeyedFloat() throws {
        struct Value: Codable, Equatable {
            let float: Float
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                float: 3.8
            )
        )
    }
    
    func testKeyedOptionalNil() throws {
        struct Value: Codable, Equatable {
            let float: Float?
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                float: nil
            )
        )
    }
    
    func testKeyedInt() throws {
        struct Value: Codable, Equatable {
            let int: Int
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                int: 3
            )
        )
    }
    
    func testKeyedInt8() throws {
        struct Value: Codable, Equatable {
            let int8: Int8
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                int8: 3
            )
        )
    }
    
    func testKeyedInt16() throws {
        struct Value: Codable, Equatable {
            let int16: Int16
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                int16: 93
            )
        )
    }
    
    func testKeyedInt32() throws {
        struct Value: Codable, Equatable {
            let int32: Int32
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                int32: 932
            )
        )
    }
    
    func testKeyedInt64() throws {
        struct Value: Codable, Equatable {
            let float: Float
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                float: 3.8
            )
        )
    }
    
    func testKeyedUint8() throws {
        struct Value: Codable, Equatable {
            let uint8: UInt8
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                uint8: 2
            )
        )
    }
    
    func testKeyedUint16() throws {
        struct Value: Codable, Equatable {
            let uni16: UInt8
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                uni16: 9
            )
        )
    }
    
    func testKeyedNested() throws {
        struct Nested: Codable, Equatable {
            let string: String
        }
        struct Value: Codable, Equatable {
            let nested: Nested
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                nested: Nested(string: "Hello")
            )
        )
    }
    
    func testUnkeyedString() throws {
        try assertDecoderSucceeds(
            type: [String].self,
            value: ["Hello", "World"]
        )
    }
    
    func testUnkeyedInt() throws {
        try assertDecoderSucceeds(
            type: [Int].self,
            value: [10, 30]
        )
    }
    
    func testUnkeyedDouble() throws {
        try assertDecoderSucceeds(
            type: [Double].self,
            value: [5.4, 1.2]
        )
    }
    
    func testUnkeyedFloat() throws {
        try assertDecoderSucceeds(
            type: [Float].self,
            value: [5.4, 9.4, 12.1]
        )
    }
    
    func testUnkeyedBool() throws {
        try assertDecoderSucceeds(
            type: [Bool].self,
            value: [true, false]
        )
    }
}
