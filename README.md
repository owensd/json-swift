json-swift
==========

A basic library for working with JSON in Swift.

Some sample usage from one of the tests:

    var json : JSON = [
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
    
    XCTAssertEqualObjects(json["stat"]?.string!, "ok")
    XCTAssertTrue(json["blogs"]?["blog"] != nil)

    XCTAssertEqualObjects(json["blogs"]?["blog"]?[0]?["id"]?.number!, 73)
    XCTAssertTrue(json["blogs"]?["blog"]?[0]?["needspassword"]?.bool!)
