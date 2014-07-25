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
        let value : JSONValue = "hello world"
        if let string = value.string {
            XCTAssertEqual(string, "hello world")
        }
        else {
            XCTFail()
        }
    }

    func testNullStringValue() {
        let string : String? = nil
        let value = JSONValue(string)
        if value.string {
            XCTFail()
        }
    }

    func testIntegerValue() {
        let value : JSONValue = 123
        if let number = value.number {
            XCTAssertEqual(number, 123)
        }
        else {
            XCTFail()
        }
    }

    func testNullIntegerValue() {
        let number : Int? = nil
        let value = JSONValue(number)
        if value.number {
            XCTFail()
        }
    }

    func testNSNumberValue() {
        let value = JSONValue(NSNumber(integer: 123))
        if let number = value.number {
            XCTAssertEqual(number, 123)
        }
        else {
            XCTFail()
        }
    }
    
    func testNullNSNumberValue() {
        let number : NSNumber? = nil
        let value = JSONValue(number)
        if value.number {
            XCTFail()
        }
    }

    func testDoubleValue() {
        let value : JSONValue = 3.234957
        if let number = value.number {
            XCTAssertEqual(number, 3.234957)
        }
        else {
            XCTFail()
        }
    }
    
    func testNullDoubleValue() {
        let number : Double? = nil
        let value = JSONValue(number)
        if value.number {
            XCTFail()
        }
    }
    
    func testBoolTrueValue() {
        let value : JSONValue = JSONValue(true)
        if let bool = value.bool {
            XCTAssertEqual(bool, true)
        }
        else {
            XCTFail()
        }
    }
    
    func testNullBoolValue() {
        let bool : Bool? = nil
        let value = JSONValue(bool)
        if value.bool {
            XCTFail()
        }
    }

    
    func testBoolFalseValue() {
        let value : JSONValue = false
        if let bool = value.bool {
            XCTAssertEqual(bool, false)
        }
        else {
            XCTFail()
        }
    }

    func testNullValue() {
        // Test disabled for bug in Swift.
        let value = JSONNull
        switch value {
        case .JSONNull:
            break;
            
        default:
            XCTFail()
        }
    }

    func testNilValue() {
        let value : JSONValue = nil
        if value != JSONNull {
            XCTFail()
        }
    }
    
    func testNullArrayValue() {
        let array : [JSONValue]? = nil
        let value = JSONValue(array)
        if value.array {
            XCTFail()
        }
    }
    
    func testNullDictionaryValue() {
        let dict : [String : JSONValue]? = nil
        let value = JSONValue(dict)
        if value.object {
            XCTFail()
        }
    }
    
    func testBasicArray() {
        let value : JSON = [1, "Dog", 3.412, true]
        if let array = value.array {
            XCTAssertEqual(array[0].number!, 1)
            XCTAssertEqual(array[1].string!, "Dog")
            XCTAssertEqual(array[2].number!, 3.412)
            XCTAssertTrue(array[3].bool!)
        }
        else {
            XCTFail()
        }
    }
    
    func testNestedArray() {
        let value : JSON = [1, "Dog", [3.412, true]]
        if let array = value.array {
            XCTAssertEqual(array[0].number!, 1)
            XCTAssertTrue(array[1].string! == "Dog")
            
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
        
        XCTAssertTrue(json["stat"].string! == "ok")
        XCTAssertTrue(json["blogs"]["blog"] != nil)
  
        XCTAssertTrue(json["blogs"]["blog"][0]["id"].number! == 73)
        XCTAssertTrue(json["blogs"]["blog"][0]["needspassword"].bool!)
    }
    
    func testFlickrWithDictAnyObjectResult() {
        var flickr : [String : AnyObject] = [
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
        
        var json = JSON(flickr)
        
        XCTAssertTrue(json["stat"].string! == "ok")
        XCTAssertTrue(json["blogs"]["blog"] != nil)
        
        XCTAssertTrue(json["blogs"]["blog"][0]["id"].number! == 73)
        XCTAssertTrue(json["blogs"]["blog"][0]["needspassword"].bool!)
    }
    
    func testFlickrResultWithNSTypes() {
        var String = "{ \"stat\": \"ok\", \"blogs\": { \"blog\": [ { \"id\" : 73, \"name\" : \"Bloxus test\", \"needspassword\" : true, \"url\" : \"http://remote.bloxus.com/\" }, { \"id\" : 74, \"name\" : \"Manila Test\", \"needspassword\" : false, \"url\" : \"http://flickrtest1.userland.com/\" } ] } }"
        var flickr : AnyObject! = NSJSONSerialization.JSONObjectWithData(String.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false), options: NSJSONReadingOptions.MutableContainers, error: nil)
        
        if let dict = flickr as? NSDictionary {
            var json = JSON(dict)
            
            XCTAssertTrue(json["stat"].string! == "ok")
            XCTAssertTrue(json["blogs"]["blog"] != nil)
            
            XCTAssertTrue(json["blogs"]["blog"][0]["id"].number! == 73)
            XCTAssertTrue(json["blogs"]["blog"][0]["needspassword"].bool!)
        }
        else {
            XCTFail("The JSON object should have been a dictionary.")
        }
    }

    func testParse() {
        var String = "{ \"stat\": \"ok\", \"blogs\": { \"blog\": [ { \"id\" : 73, \"name\" : \"Bloxus test\", \"needspassword\" : true, \"url\" : \"http://remote.bloxus.com/\" }, { \"id\" : 74, \"name\" : \"Manila Test\", \"needspassword\" : false, \"url\" : \"http://flickrtest1.userland.com/\" } ] } }"

        var parsedJson = JSON.parse(String)
        if let json = parsedJson {
            XCTAssertTrue(json["stat"].string! == "ok")
            XCTAssertTrue(json["blogs"]["blog"] != nil)
            
            XCTAssertTrue(json["blogs"]["blog"][0]["id"].number! == 73)
            XCTAssertTrue(json["blogs"]["blog"][0]["needspassword"].bool!)
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
        
        var string = json.stringify()
        var expectedString = "{\n  \"blogs\" : {\n    \"blog\" : [\n      {\n        \"url\" : \"http://remote.bloxus.com/\",\n        \"id\" : 73.0,\n        \"name\" : \"Bloxus test\",\n        \"needspassword\" : true\n      },\n      {\n        \"url\" : \"http://flickrtest1.userland.com/\",\n        \"id\" : 74.0,\n        \"name\" : \"Manila Test\",\n        \"needspassword\" : false\n      }\n    ]\n  },\n  \"stat\" : \"ok\"\n}"
        XCTAssertNotNil(string)
        XCTAssertTrue(string == expectedString)
    }
    
    func testEncodingBase64() {
        let bytes : [Byte] = [1, 2, 3, 4]
        let value = JSONValue(bytes)
        if let string = value.string {
            XCTAssertEqual(string, "data:text/plain;base64,AQIDBA==")
        }
        else {
            XCTFail()
        }
    }
    
    func testDecodingBase64() {
        let bytes : [Byte] = [1, 2, 3, 4]
        let value = JSONValue(bytes)
        if let decodedBytes = value.decodedString {
            XCTAssertEqual(bytes[0], decodedBytes[0])
            XCTAssertEqual(bytes[1], decodedBytes[1])
            XCTAssertEqual(bytes[2], decodedBytes[2])
            XCTAssertEqual(bytes[3], decodedBytes[3])
        }
        else {
            XCTFail()
        }
    }
    
    func testEquatableNullTrue() {
        let areEqual = JSONNull == JSONNull
        XCTAssertTrue(areEqual)
    }
    
    func testEquatableBoolTrue() {
        let areEqual = JSONValue(true) == JSONValue(true)
        XCTAssertTrue(areEqual)
    }
    
    func testEquatableBoolFalse() {
        let areEqual = JSONValue(true) == JSONValue(false)
        XCTAssertFalse(areEqual)
    }
    
    func testEquatableStringTrue() {
        let lhs = JSONValue("hello")
        let rhs = JSONValue("hello")
        let areEqual = lhs == rhs
        XCTAssertTrue(areEqual)
    }
    
    func testEquatableStringFalse() {
        let lhs = JSONValue("hello")
        let rhs = JSONValue("world")
        let areEqual = lhs == rhs
        XCTAssertFalse(areEqual)
    }
    
    func testEquatableNumberTrue() {
        let lhs = JSONValue(1234)
        let rhs = JSONValue(1234)
        let areEqual = lhs == rhs
        XCTAssertTrue(areEqual)
    }
    
    func testEquatableNumberFalse() {
        let lhs = JSONValue(1234)
        let rhs = JSONValue(123.4)
        let areEqual = lhs == rhs
        XCTAssertFalse(areEqual)
    }
    
    func testEquatableArrayTrue() {
        let lhs = JSONValue([1, 3, 5] as [Int])    // FIXME: compiler has an issue without the cast
        let rhs = JSONValue([1, 3, 5] as [Int])    // FIXME: compiler has an issue without the cast
        let areEqual = lhs == rhs
        XCTAssertTrue(areEqual)
    }
    
    func testEquatableArrayFalse() {
        let lhs = JSONValue([1, 3, 5] as [Int])    // FIXME: compiler has an issue without the cast
        let rhs = JSONValue([1, 3, 7] as [Int])    // FIXME: compiler has an issue without the cast
        let areEqual = lhs == rhs
        XCTAssertFalse(areEqual)
    }
    
    func testEquatableObjectTrue() {
        let lhs = JSONValue(["key1" : 1, "key2" : 3, "key3" : 5])
        let rhs = JSONValue(["key1" : 1, "key2" : 3, "key3" : 5])
        let areEqual = lhs == rhs
        XCTAssertTrue(areEqual)
    }
    
    func testEquatableObjectFalse() {
        let lhs = JSONValue(["key1" : 1, "key2" : 3, "key3" : 5])
        let rhs = JSONValue(["key3" : 1, "key2" : 3, "key1" : 5])
        let areEqual = lhs == rhs
        XCTAssertFalse(areEqual)
    }
    
    func testEquatableTypeMismatch() {
        let lhs = JSONValue(["key1" : 1, "key2" : 3, "key3" : 5])
        let rhs = JSONValue([1, 3, 5] as [Int])     // FIXME: compiler has an issue without the cast
        let areEqual = lhs == rhs
        XCTAssertFalse(areEqual)
    }
}
