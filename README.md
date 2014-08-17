json-swift
==========

A practical JSON parsing library for Swift. It provides a fully typed and validated API surface for working with JSON, including the ability to base64 items with your JSON.

All of the JSON APIs return back `FailableOf<T>` instances, instead of `Optional<T>`. This allows for richer error information to be transferred back. See [Error Handling in Swift](http://owensd.io/2014/07/09/error-handling.html) for more info.

Also, there is a functional API set for the library as well. For an in-depth overview of that, see: [Functional JSON](http://owensd.io/2014/08/06/functional-json.html).

**Initializing a JSON value**

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
    
**Retrieve data from JSON**

    if let stat = json["stat"].string {
        println("stat = '\(stat)'")
        // prints: stat = 'ok'
    }
    
**Retrieve error information from a missing key lookup**

    let stat = json["stats"]
    if let value = stat.value {
        println("stat = '\(value)'")
    }
    else if let error = stat.error {
        println("code: \(error.code), domain: '\(error.domain)', info: '\(error.userInfo[LocalizedDescriptionKey]!)'")
        // prints: code: 6, domain: 'com.kiadsoftware.json.error', info: 'There is no value stored with key: 'stats'.'
    }

**Iterate over the contents of an array**
    
    if let blogs = json["blogs"]["blog"].array {
        for blog in blogs {
            println("blog: \(blog)")
        }
    }
  
