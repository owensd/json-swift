json-swift
==========

A lightweight library for working with JSON in Swift.

Why do we need it?
------------------

Suppose you receive the following JSON and need to extract `blogs/blog/1/name`:

```json
{
    "stat": "ok",
    "blogs": {
        "blog": [
            {
                "id" : 73,
                "name" : "Bloxus test",
                "needspassword" : true,
                "url" : "http://remote.bloxus.com/"
            },
            {
                "id" : 74,
                "name" : "Manila Test",
                "needspassword" : false,
                "url" : "http://flickrtest1.userland.com/"
            }
        ]
    }
}
```
    
Swift is a type-safe language. It's usually fine, but in this case it can get you in the throat:

```swift
let json: AnyObject! = receiveSomeData()
if let name = ((((json as? NSDictionary)?["blogs"] as? NSDictionary)?["blog"]
              as? NSArray)?[1] as? NSDictionary)?["name"] as? NSString {
    // Finally, we can use the item.
} else {
    // Something went wrong. But what did?
}
```

It's a very verbose way to say we need that "Manila test". On the other side, json-swift provides a clean syntax for accessing items:

```swift
let json = JSONValue(receiveSomeData())
if let name = json["blogs"]["blog"][1]["name"].string {
    // Use the string.
} else {
    println(name.error!.localizedDescription)
}
```

Getting started
---------------

### Getting JSON data

As shown before, we can create a `JSONValue` from nested `NSDictionary` and `NSArray` objects.
We can also initialize it using an `NSData` or create inline JSON from Swift literals:

```swift
let json: JSONValue = [
    "stat": "ok",
    "blogs": [
        "blog": [
            [
                "id" : 73,
                "name" : "Bloxus test",
                "needspassword" : true,
                "url" : "http://remote.bloxus.com/"
            ],
            [
                "id" : 74,
                "name" : "Manila Test",
                "needspassword" : false,
                "url" : "http://flickrtest1.userland.com/"
            ]
        ]
    ]
]
```

### Accessing items and browsing paths

Obtaining your actual JSON value consists of 2 steps. Firstly, you provide a path using subscript chain, as shown above. Then you call one of the type-casting properties: `string`, `number` (`Double`), `integer`, `bool`, `array`, `object`. They return an `Optional` containing the required type if it is correct, and `nil` otherwise.

Don't worry if the objects you are trying to access do not exist. The result of all the subscripts will contain `NSError`, which you can access with `error` property:

```swift
let urlNode = json["blogs"]["blog"][2]["url"]
if urlNode.hasValue {
    let urlString = urlNode.string!
} else {
    let error = urlNode.error!
    println(error.localizedMessage)
}
```

In the `if` condition we check if no error occurred. In case `urlNode` is not found, at least we will see where the error occurred. In this case the message will hint us that the error began at [2] subscript.

### Modifying JSON tree

You can set any JSON node in the same manner you can access it. But make sure that the `JSONValue` is declared as a `var`, not `let`:

```swift
var modifyableJSON = json
modifyableJSON["stat"] = "fail"
assert(modifyableJSON["stat"].string! == "fail")
```

Note that Apple does not make any guarantee about the performance of such editing. The whole JSON subtree may be copied on each modification.

Installation
------------

Clone the repository to your Workspace directory and add JSON.xcodeproj to the Workspace.

Contribution
------------

Fork the repository, push your commits, then create a pull request.
