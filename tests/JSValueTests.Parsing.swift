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
    
    override func setUp() {
        self.continueAfterFailure = false
    }
    
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
    
    func testParseStringWithDoubleQuote() {
        let string = "\"Bob\""
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed, jsvalue.error?.userInfo.description ?? "No error info")
        XCTAssertEqual(jsvalue.value!.string!, "Bob")
    }

    func testParseStringWithSingleQuote() {
        let string = "'Bob'"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertEqual(jsvalue.value!.string!, "Bob")
    }
    
    func testParseStringWithEscapedQuote() {
        let string = "'Bob \"the man \" Roberts'"
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertEqual(jsvalue.value!.string!, "Bob \"the man \" Roberts")
    }

    func testParseStringWithEscapedQuoteMatchingEndQuotes() {
        let string = "\"Bob \\\"the man\\\" Roberts\""
        let jsvalue = JSValue.parse(string)
        
        XCTAssertFalse(jsvalue.failed)
        XCTAssertEqual(jsvalue.value!.string!, "Bob \\\"the man\\\" Roberts")
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
    
    func testParseDictionaryWithSingleKeyValuePair() {
        let string = "{ \"key\": 101 }"
        let json = JSON.parse(string)
        
        XCTAssertFalse(json.failed, json.error?.userInfo.description ?? "No error info")
        if let json = json.value {
            XCTAssertTrue(json.object != nil)
            XCTAssertEqual(json["key"].number!, 101)
        }
    }
    
    func testParseDictionaryWithMultipleKeyValuePairs() {
        let string = "{ \"key1\": 101, \"key2\"    :           202,\"key3\":303}"
        let json = JSON.parse(string)
        
        XCTAssertFalse(json.failed, json.error?.userInfo.description ?? "No error info")
        if let json = json.value {
            XCTAssertTrue(json.object != nil)
            XCTAssertEqual(json["key1"].number!, 101)
            XCTAssertEqual(json["key2"].number!, 202)
            XCTAssertEqual(json["key3"].number!, 303)
        }
    }
    
    func testParseMixedArray() {
        let string = "[1, -12, \"Bob\", true, false, null, -2.11234123]"
        let json = JSON.parse(string)
        
        XCTAssertFalse(json.failed, json.error?.userInfo.description ?? "No error info")
        if let json = json.value {
            XCTAssertTrue(json.array != nil)
            XCTAssertEqual(json.array!.count, 7)
            XCTAssertEqual(json[0].number!, 1)
            XCTAssertEqual(json[1].number!, -12)
            XCTAssertEqual(json[2].string!, "Bob")
            XCTAssertEqual(json[3].bool!, true)
            XCTAssertEqual(json[4].bool!, false)
            XCTAssertEqual(json[5].null, true)
            XCTAssertEqualWithAccuracy(json[6].number!, -2.11234123, 0.01)
        }
    }
    
    func testParseMixedDictionary() {
        let string = "{\"key1\": 1, \"key2\": -12, \"key3\": \"Bob\", \"key4\": true, \"key5\": false, \"key6\": null, \"key7\": -2.11234123}"
        let json = JSON.parse(string)
        
        XCTAssertFalse(json.failed, json.error?.userInfo.description ?? "No error info")
        if let json = json.value {
            XCTAssertTrue(json.object != nil)
            XCTAssertEqual(json.object!.count, 7)
            XCTAssertEqual(json["key1"].number!, 1)
            XCTAssertEqual(json["key2"].number!, -12)
            XCTAssertEqual(json["key3"].string!, "Bob")
            XCTAssertEqual(json["key4"].bool!, true)
            XCTAssertEqual(json["key5"].bool!, false)
            XCTAssertEqual(json["key6"].null, true)
            XCTAssertEqualWithAccuracy(json["key7"].number!, -2.11234123, 0.01)        }
    }
    
    func testParseNestedMixedTypes() {
        let string = "{\"key1\": 1, \"key2\": [        -12 , 12        ], \"key3\": \"Bob\", \"key4\": { 'foo': 'bar' }, \"key5\": false, \"key6\": null, \"key\\\"7\": -2.11234123}"
        let json = JSON.parse(string)
        
        XCTAssertFalse(json.failed, json.error?.userInfo.description ?? "No error info")
        if let json = json.value {
            XCTAssertTrue(json.object != nil)
            XCTAssertEqual(json.object!.count, 7)
            XCTAssertEqual(json["key1"].number!, 1)
            XCTAssertTrue(json["key2"].array != nil)
            XCTAssertEqual(json["key2"].array!.count, 2)
            XCTAssertEqual(json["key2"][0].number!, -12)
            XCTAssertEqual(json["key2"][1].number!, 12)
            XCTAssertEqual(json["key3"].string!, "Bob")
            XCTAssertTrue(json["key4"].object != nil)
            XCTAssertEqual(json["key4"]["foo"].string!, "bar")
            XCTAssertEqual(json["key5"].bool!, false)
            XCTAssertEqual(json["key6"].null, true)
            XCTAssertEqualWithAccuracy(json["key\\\"7"].number!, -2.11234123, 0.01)
        }
    }
    
    func testMutipleNestedArrayDictionaryTypes() {
        let string = "[[[[{},{},{\"ꫯ\":\"ꫯ\"}]]],[],[],[{}]]"
        let json = JSON.parse(string)

        XCTAssertFalse(json.failed, json.error?.userInfo.description ?? "No error info")
    }
    
    func testParsingSampleJSON() {
        let path = NSBundle(forClass: JSValuePerformanceTests.self).pathForResource("sample", ofType: "json")
        XCTAssertNotNil(path)
        
        let string = NSString.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil)
        XCTAssertNotNil(string)
        
        let json = JSON.parse(string)
        XCTAssertFalse(json.failed, json.error?.userInfo.description ?? "No error message found")
    }
}