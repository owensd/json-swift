//
//  JSONTests.swift
//  JSONTests
//
//  Created by David Owens on 6/20/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

import XCTest
import JSONLib

class JSONTests: XCTestCase {
    
    func testStringValue() {
        let value : JSValue = "hello world"
        if let string = value.string {
            XCTAssertEqual(string, "hello world")
        }
        else {
            XCTFail()
        }
    }

    func testNullStringValue() {
        let string : String? = nil
        let value = JSValue(string)
        if value.string != nil {
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

    func testNullIntegerValue() {
        let number : Int? = nil
        let value = JSValue(number)
        if value.number != nil {
            XCTFail()
        }
    }

    func testNSNumberValue() {
        let value = JSValue(NSNumber(integer: 123))
        if let number = value.number {
            XCTAssertEqual(number, 123)
        }
        else {
            XCTFail()
        }
    }
    
    func testNullNSNumberValue() {
        let number : NSNumber? = nil
        let value = JSValue(number)
        if value.number != nil {
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
    
    func testNullDoubleValue() {
        let number : Double? = nil
        let value = JSValue(number)
        if value.number != nil {
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
    
    func testNullBoolValue() {
        let bool : Bool? = nil
        let value = JSValue(bool)
        if value.bool != nil {
            XCTFail()
        }
    }

    
    func testBoolFalseValue() {
        let value : JSValue = false
        if let bool = value.bool {
            XCTAssertEqual(bool, false)
        }
        else {
            XCTFail()
        }
    }

    func testNilValue() {
        let value: JSON = nil
        switch value {
        case .JSNull:
            break;
            
        default:
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
        if let json = parsedJson.value {
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
        
        let string = json.stringify()
        XCTAssertFalse(string.failed)

        let jsonFromString = JSON.parse(string.value!)
        XCTAssertFalse(jsonFromString.failed)
        XCTAssertEqual(jsonFromString.value!["stat"].string!, "ok")
        XCTAssertEqual(jsonFromString.value!["blogs"]["blog"][0]["name"].string!, "Bloxus test")
    }
    
    func testEncodingBase64() {
        let bytes : [Byte] = [1, 2, 3, 4]
        let value = JSValue(bytes)
        if let string = value.string {
            XCTAssertEqual(string, "data:text/plain;base64,AQIDBA==")
        }
        else {
            XCTFail()
        }
    }
    
    func testDecodingBase64() {
        let bytes : [Byte] = [1, 2, 3, 4]
        let value = JSValue(bytes)
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
        let x: JSON = nil
        let y: JSON = nil
        let areEqual = x == y
        XCTAssertTrue(areEqual)
    }
    
    func testEquatableBoolTrue() {
        let areEqual = JSValue(true) == JSValue(true)
        XCTAssertTrue(areEqual)
    }
    
    func testEquatableBoolFalse() {
        let areEqual = JSValue(true) == JSValue(false)
        XCTAssertFalse(areEqual)
    }
    
    func testEquatableStringTrue() {
        let lhs = JSValue("hello")
        let rhs = JSValue("hello")
        let areEqual = lhs == rhs
        XCTAssertTrue(areEqual)
    }
    
    func testEquatableStringFalse() {
        let lhs = JSValue("hello")
        let rhs = JSValue("world")
        let areEqual = lhs == rhs
        XCTAssertFalse(areEqual)
    }
    
    func testEquatableNumberTrue() {
        let lhs = JSValue(1234)
        let rhs = JSValue(1234)
        let areEqual = lhs == rhs
        XCTAssertTrue(areEqual)
    }
    
    func testEquatableNumberFalse() {
        let lhs = JSValue(1234)
        let rhs = JSValue(123.4)
        let areEqual = lhs == rhs
        XCTAssertFalse(areEqual)
    }
    
    func testEquatableArrayTrue() {
        let lhs = JSValue([1, 3, 5] as [Int])    // FIXME: compiler has an issue without the qualifier
        let rhs = JSValue([1, 3, 5] as [Int])    // FIXME: compiler has an issue without the qualifier
        let areEqual = lhs == rhs
        XCTAssertTrue(areEqual)
    }
    
    func testEquatableArrayFalse() {
        let lhs = JSValue([1, 3, 5] as [Int])    // FIXME: compiler has an issue without the qualifier
        let rhs = JSValue([1, 3, 7] as [Int])    // FIXME: compiler has an issue without the qualifier
        let areEqual = lhs == rhs
        XCTAssertFalse(areEqual)
    }
    
    func testEquatableObjectTrue() {
        let lhs = JSValue(["key1" : 1, "key2" : 3, "key3" : 5])
        let rhs = JSValue(["key1" : 1, "key2" : 3, "key3" : 5])
        let areEqual = lhs == rhs
        XCTAssertTrue(areEqual)
    }
    
    func testEquatableObjectFalse() {
        let lhs = JSValue(["key1" : 1, "key2" : 3, "key3" : 5])
        let rhs = JSValue(["key3" : 1, "key2" : 3, "key1" : 5])
        let areEqual = lhs == rhs
        XCTAssertFalse(areEqual)
    }
    
    func testEquatableTypeMismatch() {
        let lhs = JSValue(["key1" : 1, "key2" : 3, "key3" : 5])
        let items = [1, 3, 5]
        let rhs = JSValue(items)
        
        let areEqual = lhs == rhs
        XCTAssertFalse(areEqual)
    }
    
    func testArrayAssignment() {
        var items = [1, 2, 3, 4]
        var array = JSValue(items)
        array[2] = 10
        
        XCTAssertEqual(countElements(array.array!), 4)
        XCTAssertEqual(array.array![2], 10)
    }
    
    func testDictionaryAssignment() {
        var dict = JSValue(["key1" : 1, "key2" : 3, "key3" : 5])
        dict["key2"] = 10
        
        XCTAssertEqual(countElements(dict.object!), 3)
        let value = dict.object!["key2"]
        XCTAssertEqual(value!.number!, 10)
    }
}
