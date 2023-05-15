import XCTest
import JavaScriptCore
import JSValueCoder

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
    
    // MARK: - Keyed
    
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
    
    func testKeyedUUID() throws {
        struct Value: Codable, Equatable {
            let uuid: UUID
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                uuid: UUID()
            )
        )
    }
    
    func testKeyedURL() throws {
        struct Value: Codable, Equatable {
            let url: URL
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                url: URL(string: "https://github.com")!
            )
        )
    }
    
    func testKeyedEnum() throws {
        enum Nested: String, Codable, Equatable {
            case first
            case second
        }
        struct Value: Codable, Equatable {
            let `enum`: Nested
        }
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                enum: .first
            )
        )
    }
    
    func testKeyedDate() throws {
        struct Value: Codable, Equatable {
            let date: Date
        }

        let input = "2023-05-15T07:07:46Z"

        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: input)!
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                date: date
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
                int8: Int8.max
            )
        )
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                int8: Int8.min
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
            let int64: Int64
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                int64: -8876
            )
        )
    }
    
    func testKeyedUint() throws {
        struct Value: Codable, Equatable {
            let uint: UInt
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                uint: 2
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
            let uni16: UInt16
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                uni16: 9
            )
        )
    }
    
    func testKeyedUint64() throws {
        struct Value: Codable, Equatable {
            let uni64: UInt64
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                uni64: 9998
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
    
    func testKeyedStrings() throws {
        struct Value: Codable, Equatable {
            let strings: [String]
        }
        
        try assertDecoderSucceeds(
            type: Value.self,
            value: Value(
                strings: ["Hello", "World"]
            )
        )
    }
    
    // MARK: - Unkeyed
    
    func testUnkeyedString() throws {
        try assertDecoderSucceeds(
            type: [String].self,
            value: ["Hello", "World"]
        )
    }
    
    func testUnkeyedOptionalString() throws {
        try assertDecoderSucceeds(
            type: [String?].self,
            value: ["Hello", "World", nil]
        )
    }
    
    func testUnkeyedBool() throws {
        try assertDecoderSucceeds(
            type: [Bool].self,
            value: [true, false]
        )
    }
    
    func testUnkeyedInt() throws {
        try assertDecoderSucceeds(
            type: [Int].self,
            value: [10, 30]
        )
    }
    
    func testUnkeyedInt8() throws {
        try assertDecoderSucceeds(
            type: [Int8].self,
            value: [10, 30]
        )
    }
    
    func testUnkeyedInt16() throws {
        try assertDecoderSucceeds(
            type: [Int16].self,
            value: [10, 30]
        )
    }
    
    func testUnkeyedInt32() throws {
        try assertDecoderSucceeds(
            type: [Int32].self,
            value: [10, 30]
        )
    }
    
    func testUnkeyedInt64() throws {
        try assertDecoderSucceeds(
            type: [Int64].self,
            value: [10, 30]
        )
    }
    
    func testUnkeyedUInt() throws {
        try assertDecoderSucceeds(
            type: [UInt].self,
            value: [10, 30]
        )
    }
    
    func testUnkeyedUint8() throws {
        try assertDecoderSucceeds(
            type: [UInt8].self,
            value: [10, 30]
        )
    }
    
    func testUnkeyedUInt16() throws {
        try assertDecoderSucceeds(
            type: [UInt16].self,
            value: [10, 30]
        )
    }
    
    func testUnkeyedUInt64() throws {
        try assertDecoderSucceeds(
            type: [UInt64].self,
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
    
    func testUnkeyedDate() throws {
        
        let input = "2023-05-15T07:07:46Z"

        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: input)!
        
        try assertDecoderSucceeds(
            type: [Date].self,
            value: [date, date, date]
        )
    }
    
    func testUnkeyedNested() throws {
        struct Nested: Codable, Equatable {
            let string: String
        }
        
        let value: [Nested] = [
            Nested(string: "Hello"),
            Nested(string: "World")
        ]
        
        try assertDecoderSucceeds(
            type: [Nested].self,
            value: value
        )
    }
}
