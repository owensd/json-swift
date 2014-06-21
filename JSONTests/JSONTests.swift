//
//  JSONTests.swift
//  JSONTests
//
//  Created by David Owens on 6/20/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

import XCTest
import JSON

class JSONTests: XCTestCase {
    
    func testStringValue() {
        let value : JSValue = "hello world"
        if let string = value.string {
            XCTAssertEqualObjects(string, "hello world")
        }
        else {
            XCTFail()
        }
    }
    
    func testIntegerValue() {
        let value : JSValue = 123
        if let number = value.number {
            XCTAssertEqual(number, 123)
        }
        else {
            XCTFail()
        }
    }
    
    func testDoubleValue() {
        let value : JSValue = 3.234957
        if let number = value.number {
            XCTAssertEqual(number, 3.234957)
        }
        else {
            XCTFail()
        }
    }
    
    func testBoolTrueValue() {
        let value : JSValue = JSValue(true)
        if let bool = value.bool {
            XCTAssertEqual(bool, true)
        }
        else {
            XCTFail()
        }
    }
    
    func testBoolFalseValue() {
        let value : JSValue = JSFalse
        if let bool = value.bool {
            XCTAssertEqual(bool, false)
        }
        else {
            XCTFail()
        }
    }

//    func testNullValue() {
//        // Test disabled for bug in Swift.
//        let value = JSValue(nil)
//        switch value {
//        case .JSNull:
//            break;
//            
//        default:
//            XCTFail()
//        }
//    }
    
    func testBasicArray() {
        let value : JSON = [1, "Dog", 3.412, JSTrue]
        if let array = value.array {
            XCTAssertEqual(array[0].number!, 1)
            XCTAssertEqualObjects(array[1].string!, "Dog")
            XCTAssertEqual(array[2].number!, 3.412)
            XCTAssertTrue(array[3].bool!)
        }
        else {
            XCTFail()
        }
    }
    
    func testNestedArray() {
        let value : JSON = [1, "Dog", [3.412, JSTrue]]
        if let array = value.array {
            XCTAssertEqual(array[0].number!, 1)
            XCTAssertEqualObjects(array[1].string!, "Dog")
            
            let nested = array[2].array!
            XCTAssertEqual(nested[0].number!, 3.412)
            XCTAssertTrue(nested[1].bool!)
        }
        else {
            XCTFail()
        }
    }
    
    func testFlickrResult() {
        var json : JSON = [
            "stat": "ok",
            "blogs": [
                "blog": [
                    [
                        "id" : 73,
                        "name" : "Bloxus test",
                        "needspassword" : JSTrue,
                        "url" : "http://remote.bloxus.com/"
                    ],
                    [
                        "id" : 74,
                        "name" : "Manila Test",
                        "needspassword" : JSFalse,
                        "url" : "http://flickrtest1.userland.com/"
                    ]
                ]
            ]
        ]
        
        XCTAssertEqualObjects(json["stat"]?.string!, "ok")
        XCTAssertTrue(json["blogs"]?["blog"] != nil)
  
        XCTAssertEqualObjects(json["blogs"]?["blog"]?[0]?["id"]?.number!, 73)
        XCTAssertTrue(json["blogs"]?["blog"]?[0]?["needspassword"]?.bool!)
    }

    func testParse() {
        var jsonString = "{ \"stat\": \"ok\", \"blogs\": { \"blog\": [ { \"id\" : 73, \"name\" : \"Bloxus test\", \"needspassword\" : true, \"url\" : \"http://remote.bloxus.com/\" }, { \"id\" : 74, \"name\" : \"Manila Test\", \"needspassword\" : false, \"url\" : \"http://flickrtest1.userland.com/\" } ] } }"

        var parsedJson = JSON.parse(jsonString)
        if let json = parsedJson {
            XCTAssertEqualObjects(json["stat"]?.string!, "ok")
            XCTAssertTrue(json["blogs"]?["blog"] != nil)
            
            XCTAssertEqualObjects(json["blogs"]?["blog"]?[0]?["id"]?.number!, 73)
            XCTAssertTrue(json["blogs"]?["blog"]?[0]?["needspassword"]?.bool!)
        }
        else {
            XCTFail()
        }
    }
    
    func testStringify() {
        var json : JSON = [
            "stat": "ok",
            "blogs": [
                "blog": [
                    [
                        "id" : 73,
                        "name" : "Bloxus test",
                        "needspassword" : JSTrue,
                        "url" : "http://remote.bloxus.com/"
                    ],
                    [
                        "id" : 74,
                        "name" : "Manila Test",
                        "needspassword" : JSFalse,
                        "url" : "http://flickrtest1.userland.com/"
                    ]
                ]
            ]
        ]
        
        var jsonString = json.stringify()
        var expectedString = "{\n  \"blogs\" : {\n    \"blog\" : [\n      {\n        \"url\" : \"http://remote.bloxus.com/\",\n        \"id\" : 73.0,\n        \"name\" : \"Bloxus test\",\n        \"needspassword\" : true\n      },\n      {\n        \"url\" : \"http://flickrtest1.userland.com/\",\n        \"id\" : 74.0,\n        \"name\" : \"Manila Test\",\n        \"needspassword\" : false\n      }\n    ]\n  },\n  \"stat\" : \"ok\"\n}"
        XCTAssertNotNil(jsonString)
        XCTAssertEqualObjects(jsonString, expectedString)
    }
}
