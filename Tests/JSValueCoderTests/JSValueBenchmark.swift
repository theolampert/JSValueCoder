//
//  JSValueBenchmark.swift
//  
//
//  Created by Theodore Lampert on 15.05.23.
//

import XCTest
//import Foundation
import JavaScriptCore
import JSValueCoder

final class JSValueBenchmark: XCTestCase {
    enum State: Codable, Equatable {
        case open
        case closed
        case loading
    }
    
    struct Point: Codable, Equatable {
        let id: UUID
        let x: Double
        let y: Double
    }
    
    struct Shape: Codable, Equatable {
        let id: UUID
        let name: String
        let createdAt: Date
        let updatedAt: Date
        let shape: [Point]
        let visibility: Int8
        let score: Int
    }
    
    struct Container: Codable, Equatable {
        let id: UUID
        let shapes: [Shape]
    }
    
    lazy var shapes: [Shape] = {
        let totalShapes = 1400
        let totalPoints = 10
        return (0...totalShapes).map { int in
            return Shape(
                id: UUID(),
                name: "Shape",
                createdAt: Date(),
                updatedAt: Date(),
                shape: (0...totalPoints).map { _ in Point(id: UUID(), x: 1.5, y: 16.3) },
                visibility: 2,
                score: int
            )
        }
    }()
    
    lazy var container: Container = {
        Container(id: UUID(), shapes: shapes)
    }()

    func testCodableBenchmark() throws {
        let context = JSContext()!
        let encoder = JSValueEncoder()
        let decoder = JSValueDecoder()
        
        measure {
            let encoded: JSValue = try! encoder.encode(container, in: context)
            context.setObject(encoded, forKeyedSubscript: "data" as NSString & NSCopying)
            let res = context.evaluateScript("data")!
            _ = try! decoder.decode(Container.self, from: res)
        }
    }
    
    func testJSONMarshallingBenchmark() throws {
        let context = JSContext()!
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        measure {
            let encoded: Data = try! encoder.encode(container)
            context.setObject(
                String(data: encoded, encoding: .utf8),
                forKeyedSubscript: "data" as NSString & NSCopying
            )
            context.evaluateScript("""
            data = JSON.stringify(JSON.parse(data))
            """)
            let res = context.evaluateScript("data")!.toString()!
            _ = try! decoder.decode(Container.self, from: res.data(using: .utf8)!)
        }
    }
}
