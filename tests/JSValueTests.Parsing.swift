//
//  JSValueTests.Parsing.swift
//  JSON
//
//  Created by David Owens II on 8/12/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

import XCTest
import JSONLib

class JSValueParsingTests : XCTestCase {
    
    func testParseNull() {
        let string = "null"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertTrue(jsvalue.value?.null == true)
    }

    func testParseNullWithWhitespace() {
        let string = "  \r\n\n\r\t\t\t\tnull\t\t\t\t\t\t\t       \n\r\r\n\n\n"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertTrue(jsvalue.value?.null == true)
    }
    
    func testParseNullInvalidJSON() {
        let string = "null,"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertTrue(jsvalue.failed)
        // TODO: Validate the error information
    }

    func testParseTrue() {
        let string = "true"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertTrue(jsvalue.value?.bool == true)
    }
    
    func testParseTrueWithWhitespace() {
        let string = "  \r\n\n\r\t\t\t\ttrue\t\t\t\t\t\t\t       \n\r\r\n\n\n"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertTrue(jsvalue.value?.bool == true)
    }
    
    func testParseTrueInvalidJSON() {
        let string = "true#"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertTrue(jsvalue.failed)
        // TODO: Validate the error information
    }
    
    func testParseFalse() {
        let string = "false"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertTrue(jsvalue.value?.bool == false)
    }
    
    func testParseFalseWithWhitespace() {
        let string = "  \r\n\n\r\t\t\t\tfalse\t\t\t\t\t\t\t       \n\r\r\n\n\n"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertTrue(jsvalue.value?.bool == false)
    }
    
    func testParseFalseInvalidJSON() {
        let string = "false-"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertTrue(jsvalue.failed)
        // TODO: Validate the error information
    }
    
    func testParseInteger() {
        let string = "101"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertTrue(jsvalue.value?.number == 101)
    }

    func testParseNegativeInteger() {
        let string = "-109234"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertTrue(jsvalue.value?.number == -109234)
    }
    
    func testParseDouble() {
        let string = "12.345678"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertEqualWithAccuracy(jsvalue.value!.number!, 12.345678, 0.01)
    }
    
    func testParseNegativeDouble() {
        let string = "-123.949"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertEqualWithAccuracy(jsvalue.value!.number!, -123.949, 0.01)
    }

    func testParseExponent() {
        let string = "12.345e2"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertEqualWithAccuracy(jsvalue.value!.number!, 12.345e2, 0.01)
    }

    func testParsePositiveExponent() {
        let string = "12.345e+2"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertEqualWithAccuracy(jsvalue.value!.number!, 12.345e+2, 0.01)
    }
    
    func testParseNegativeExponent() {
        let string = "-123.9492e-5"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertEqualWithAccuracy(jsvalue.value!.number!, -123.9492e-5, 0.01)
    }

    func testParseEmptyDictionary() {
        let string = "{}"
        let json = JSON.parse(string)
        
        XCTAssertFalse(json.failed)
        if let json = json.value {
            XCTAssertTrue(json.object != nil)
        }
    }

    func testParseEmptyDictionaryWithExtraWhitespace() {
        let string = "         {\r\n\n\n\n     \t \t}   \t \t"
        let json = JSON.parse(string)
        
        XCTAssertFalse(json.failed)
        if let json = json.value {
            XCTAssertTrue(json.object != nil)
        }
    }

    func testParseEmptyArray() {
        let string = "[]"
        let json = JSON.parse(string)
        
        XCTAssertFalse(json.failed)
        if let json = json.value {
            XCTAssertTrue(json.array != nil)
        }
    }
    
    func testSingleElementArray() {
        let string = "[101]"
        let json = JSON.parse(string)
        
        XCTAssertFalse(json.failed)
        if let json = json.value {
            XCTAssertTrue(json.array != nil)
            XCTAssertTrue(json.array?.count == 1)
            XCTAssertTrue(json[0] == 101)
        }
    }

    func testMultipleElementArray() {
        let string = "[101, 202, 303]"
        let json = JSON.parse(string)
        
        XCTAssertFalse(json.failed)
        if let json = json.value {
            XCTAssertTrue(json.array != nil)
            XCTAssertTrue(json.array?.count == 3)
            XCTAssertTrue(json[0] == 101)
            XCTAssertTrue(json[1] == 202)
            XCTAssertTrue(json[2] == 303)
        }
    }
//    func testParseMixedArray() {
//        let string = "[1, -12, \"Bob\", true, false, null, -2.11234123]"
//        let json = JSON.parse(string)
//        
//        XCTAssertFalse(json.failed)
//        if let json = json.value {
//            XCTAssertTrue(json.array != nil)
//            XCTAssertEqual(json.array!.count, 7)
//            XCTAssertTrue(json[0].number == 1)
//            XCTAssertTrue(json[1].number == -12)
//            XCTAssertTrue(json[2].string == "Bob")
//            XCTAssertTrue(json[3].bool == true)
//            XCTAssertTrue(json[4].bool == false)
//            XCTAssertTrue(json[5].null == true)
//            XCTAssertTrue(json[6].number == -2.11234123)
//        }
//    }
    
//    func testParseMixedDictionary() {
//        let string = "{\"key1\": 1, \"key2\": -12, \"key3\": \"Bob\", \"key4\": true, \"key5\": false, \"key6\": null, \"key7\": -2.11234123}"
//        let json = JSON.parse(string)
//        
//        XCTAssertFalse(json.failed)
//        if let json = json.value {
//            XCTAssertTrue(json.object != nil)
//        }
//    }
}