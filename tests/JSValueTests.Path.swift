//
//  JSValueTests.Path.swift
//  JSON
//
//  Created by Ranchao Zhang on 8/27/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

import XCTest
import JSONLib

class JSValuePathTests : XCTestCase {
    func testBasicGet() {
        var value: JSValue = [1, "Dog", 3.412, true]
        XCTAssertTrue(value.hasValue)
        XCTAssertTrue(value.get("0").number? == 1)
        XCTAssertTrue(value.get("1").string? == "Dog")
        XCTAssertTrue(value.get("2").number? == 3.412)
        XCTAssertTrue(value.get("3").bool? == true)

        let newValue: JSValue = "Cat"
        value.set("1", obj: newValue)
        XCTAssertTrue(value.hasValue)
        XCTAssertTrue(value.get("0").number? == 1)
        XCTAssertTrue(value.get("1").string? == "Cat")
        XCTAssertTrue(value.get("2").number? == 3.412)
        XCTAssertTrue(value.get("3").bool? == true)
        
        value[1] = "Mouse"
        XCTAssertTrue(value.hasValue)
        XCTAssertTrue(value.get("0").number? == 1)
        XCTAssertTrue(value.get("1").string? == "Mouse")
        XCTAssertTrue(value.get("2").number? == 3.412)
        XCTAssertTrue(value.get("3").bool? == true)
    }
    
    func testNestedArrayGet() {
        var value: JSON = [1, "Dog", [3.412, true]]
        XCTAssertTrue(value.hasValue)
        XCTAssertTrue(value.get("0").number? == 1)
        XCTAssertTrue(value.get("1").string? == "Dog")
        
        value.set("2.0", obj: 1.123)
        XCTAssertTrue(value.get("2.0").number? == 1.123)
        XCTAssertTrue(value.get("2.1").bool? == true)
    }
    
    func testNestedMixedTypes() {
        var json: JSON = [
            "stat": "ok",
            "blogs": [
                "blog": [
                    [
                        "id": 73,
                        "name": "Bloxus test",
                        "needspassword": true,
                        "url": "http://remote.bloxus.com/"
                    ],
                    [
                        "id": 74,
                        "name": "Manila Test",
                        "needspassword": false,
                        "url": "http://flickrtest1.userland.com/"
                    ]
                ]
            ]
        ]
        
        XCTAssertTrue(json.hasValue)
        XCTAssertTrue(json.get("stat").string? == "ok")
        XCTAssertTrue(json.get("blogs.blog").hasValue)
        XCTAssertTrue(json.get("blogs.blog.0.id").number? == 73)
        XCTAssertTrue(json.get("blogs.blog.0.needspassword").bool? == true)
        
        json.set("blogs.blog.0.needspassword", obj: false)
        XCTAssertTrue(json.hasValue)
        XCTAssertTrue(json.get("stat").string? == "ok")
        XCTAssertTrue(json.get("blogs.blog").hasValue)
        XCTAssertTrue(json.get("blogs.blog.0.id").number? == 73)
        XCTAssertTrue(json.get("blogs.blog.0.needspassword").bool? == false)
    }
}