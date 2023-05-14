### JSValueCoder

![Test](https://github.com/theolampert/JSValueCoder/actions/workflows/swift.yml/badge.svg)

Codable implementation for JavascriptCore's `JSValue`

#### Usage:
```swift
let context = JSContext()!

struct User: Codable {
    let id: String
    let name: String
    let score: Double
}

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
```


#### Notes:
This was based off of work done here [here](https://github.com/byss/KBJSValueCoding), support was added for nested structs and arrays and tests added.
