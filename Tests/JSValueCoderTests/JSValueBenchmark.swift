//
//  JSValueBenchmark.swift
//  
//
//  Created by Theodore Lampert on 15.05.23.
//

import XCTest
import Foundation
import JavaScriptCore
import JSValueCoder

final class JSValueBenchmark: XCTestCase {
    struct Point: Codable, Equatable {
        let x: Double
        let y: Double
    }
    
    struct Shape: Codable, Equatable {
        let id: UUID
        let name: String
        let createdAt: Date
        let updatedAt: Date
        let shape: [Point]
    }
    
    lazy var shapes: [Shape] = {
        let totalShapes = 15000
        let totalPoints = 10
        return (0...totalShapes).map { int in
            return Shape(
                id: UUID(),
                name: "Shape",
                createdAt: Date(),
                updatedAt: Date(),
                shape: (0...totalPoints).map { _ in Point(x: 1.5, y: 16.3) }
            )
        }
    }()

    func testCodableBenchmark() throws {
        let context = JSContext()!
        let encoder = JSValueEncoder()
        let decoder = JSValueDecoder()
        
        measure {
            let encoded: JSValue = try! encoder.encode(shapes, in: context)
            context.setObject(encoded, forKeyedSubscript: "data" as NSString & NSCopying)
            let res = context.evaluateScript("data")!
            _ = try! decoder.decode([Shape].self, from: res)
        }
    }
    
    func testJSONMarshallingBenchmark() throws {
        let context = JSContext()!
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        measure {
            let encoded: Data = try! encoder.encode(shapes)
            context.setObject(
                String(data: encoded, encoding: .utf8),
                forKeyedSubscript: "data" as NSString & NSCopying
            )
            context.evaluateScript("""
            data = JSON.parse(data)
            data = JSON.stringify(data)
            """)
            let res = context.evaluateScript("data")!.toString()!
            _ = try! decoder.decode([Shape].self, from: res.data(using: .utf8)!)
        }
    }
}
