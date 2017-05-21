json-swift
==========

![build status badge](https://travis-ci.org/owensd/json-swift.svg?branch=master)

A practical JSON parsing library for Swift. It provides a fully typed and validated API surface for
working with JSON, including the ability to base64 items with your JSON.

All of the JSON APIs return back of `Optional<T>`. This allows for easier use for deep indexing. In
addition, there is an `Optional<JSValue>` wrapper for all indexers and accessors which removes all
of the `?` jumping that is normally required.

Also, there is a functional API set for the library as well. For an in-depth overview of that, see:
[Functional JSON](http://owensd.io/2014/08/06/functional-json.html).

**Initializing a JSON value**

```swift
let json : JSON = [
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
    
**Retrieve data from JSON**

```swift
if let stat = json["stat"].string {
    println("stat = '\(stat)'")
    // prints: stat = 'ok'
}
```

**Retrieve error information from a missing key lookup**

```swift
let stat = json["stats"]
if let value = stat.string {
    println("stat = '\(value)'")
}
else if let error = stat.error {
    println("code: \(error.code), domain: '\(error.domain)', info: '\(error.userInfo[LocalizedDescriptionKey]!)'")
    // prints: code: 6, domain: 'com.kiadstudios.json.error', info: 'There is no value stored with key: 'stats'.'
}
```

**Iterate over the contents of an array**
 
```swift   
if let blogs = json["blogs"]["blog"].array {
    for blog in blogs {
        println("blog: \(blog)")
    }
}
```
  
See `JSValueTests.Usage.swift` for more usage samples.
