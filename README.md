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

This was originally based off of work here https://github.com/byss/KBJSValueCoding with the following changes:

- Support was added for nested structs
- Support was added for arrays
- Bug was fixed when decoding Bools
- Tests added
