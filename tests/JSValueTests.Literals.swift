//
//  JSON.Literals.swift
//  JSON
//
//  Created by David Owens II on 8/11/14.
//  Copyright (c) 2014 David Owens II. All rights reserved.
//

import XCTest
import JSONLib

class JSValueLiteralsTests : XCTestCase {
    
    func testStringValue() {
        let value: JSValue = "hello world"
        XCTAssertTrue(value.hasValue)
        XCTAssertTrue(value.string?.compare("hello world") == NSComparisonResult.OrderedSame)
    }

    func testCompareStringToNonStringValue() {
        let value: JSValue = 1234
        XCTAssertTrue(value.hasValue)
        XCTAssertFalse(value.string?.compare("1234") == NSComparisonResult.OrderedSame)
    }

    func testIntegerValue() {
        let value: JSValue = 123
        XCTAssertTrue(value.hasValue)
        XCTAssertTrue(value.number == 123)
    }
    
    func testUnderUnsafeMinimumIntegerValue() {
        let value: JSValue = -9007199254740992
        XCTAssertFalse(value.hasValue)
        XCTAssertTrue(value.error != nil)
    }
    
    func testOverUnsafeMaximumIntegerValue() {
        let value: JSValue = 9007199254740992
        XCTAssertFalse(value.hasValue)
        XCTAssertTrue(value.error != nil)
    }
    
    func testUnsafeMinimumIntegerValue() {
        let value: JSValue = -9007199254740991
        XCTAssertTrue(value.hasValue)
    }
    
    func testUnsafeMaximumIntegerValue() {
        let value: JSValue = 9007199254740991
        XCTAssertTrue(value.hasValue)
    }
    
    func testDoubleValue() {
        let value: JSValue = 3.1245123123
        XCTAssertTrue(value.hasValue)
        XCTAssertTrue(value.number == 3.1245123123)
    }

    func testBoolTrueValue() {
        let value: JSValue = true
        XCTAssertTrue(value.hasValue)
        XCTAssertTrue(value.bool == true)
    }
    
    func testBoolFalseValue() {
        let value: JSValue = false
        XCTAssertTrue(value.hasValue)
        XCTAssertTrue(value.bool == false)
    }

    func testNilValue() {
        let value: JSValue = nil
        XCTAssertTrue(value.hasValue)
        XCTAssertTrue(value.null)
    }
    
    func testBasicArray() {
        let value: JSON = [1, "Dog", 3.412, true]
        XCTAssertTrue(value.hasValue)
        XCTAssertTrue(value[0].number == 1)
        XCTAssertTrue(value[1].string == "Dog")
        XCTAssertTrue(value[2].number == 3.412)
        XCTAssertTrue(value[3].bool == true)
    }
    
    func testNestedArray() {
        let value: JSON = [1, "Dog", [3.412, true]]
        XCTAssertTrue(value.hasValue)
        XCTAssertTrue(value[0].number == 1)
        XCTAssertTrue(value[1].string == "Dog")
        
        // Usage #1
        if let array = value[2].array {
            XCTAssertTrue(array[0].number == 3.412)
            XCTAssertTrue(array[1].bool == true)
        }
        else {
            XCTFail()
        }

        // Usage #2
        XCTAssertTrue(value[2][0].number == 3.412)
        XCTAssertTrue(value[2][1].bool == true)
    }
    
    func testFlickrResult() {
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
        
        XCTAssertTrue(json["stat"].string == "ok")

        XCTAssertTrue(json["blogs"]["blog"].hasValue)
        XCTAssertTrue(json["blogs"]["blog"][0]["id"].number == 73)
        XCTAssertTrue(json["blogs"]["blog"][0]["needspassword"].bool == true)
    }
}