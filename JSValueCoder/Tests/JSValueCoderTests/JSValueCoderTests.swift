import XCTest
import JavaScriptCore
@testable import JSValueCoder

final class JSValueCoderTests: XCTestCase {
    func testNested() throws {
        struct Note: Codable, Equatable {
            let id: Int
        }

        struct User: Codable, Equatable {
            let id: String
            let name: String
            let score: Double
            let note: Note?
        }
        
        let context = JSContext()!

        let user = User(
            id: "7",
            name: "John",
            score: 1.3,
            note: Note(id: 1)
        )

        let encoder = JSValueEncoder()
        let decoder = JSValueDecoder()

        let jsValue = try encoder.encode(user, in: context)
        let decoded = try decoder.decode(User.self, from: jsValue)
        XCTAssertEqual(decoded, user)
    }
    
    func testUnkeyed() throws {
        let context = JSContext()!

        let notes: [String] = ["Hello", "World"]

        let encoder = JSValueEncoder()
        let decoder = JSValueDecoder()

        let jsValue = try encoder.encode(notes, in: context)
        let decoded = try decoder.decode([String].self, from: jsValue)

        XCTAssertEqual(decoded, notes)
    }

}
