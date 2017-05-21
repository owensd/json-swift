/* --------------------------------------------------------------------------------------------
 * Copyright (c) Kiad Studios, LLC. All rights reserved.
 * Licensed under the MIT License. See License in the project root for license information.
 * ------------------------------------------------------------------------------------------ */

import XCTest
import JSONLib

class JSValueParsingTests : XCTestCase {
    
    override func setUp() {
        self.continueAfterFailure = false
    }
    
    func testParseNull() {
        let string = "null"
        let jsvalue = try? JSValue.parse(string)

        XCTAssertTrue(jsvalue != nil)
        XCTAssertTrue(jsvalue.null == true)
    }

    func testParseNullWithWhitespace() {
        let string = "  \r\n\n\r\t\t\t\tnull\t\t\t\t\t\t\t       \n\r\r\n\n\n"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertTrue(jsvalue.null == true)
    }
    
    func testParseNullInvalidJSON() {
        let string = "null,"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue == nil)
        // TODO: Validate the error information
    }

    func testParseTrue() {
        let string = "true"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertTrue(jsvalue.bool == true)
    }
    
    func testParseTrueWithWhitespace() {
        let string = "  \r\n\n\r\t\t\t\ttrue\t\t\t\t\t\t\t       \n\r\r\n\n\n"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertTrue(jsvalue.bool == true)
    }
    
    func testParseTrueInvalidJSON() {
        let string = "true#"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue == nil)
        // TODO: Validate the error information
    }
    
    func testParseFalse() {
        let string = "false"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertTrue(jsvalue.bool == false)
    }
    
    func testParseFalseWithWhitespace() {
        let string = "  \r\n\n\r\t\t\t\tfalse\t\t\t\t\t\t\t       \n\r\r\n\n\n"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertTrue(jsvalue.bool == false)
    }
    
    func testParseFalseInvalidJSON() {
        let string = "false-"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue == nil)
        // TODO: Validate the error information
    }
    
    func testParseStringWithDoubleQuote() {
        let string = "\"Bob\""
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertEqual(jsvalue.string, "Bob")
    }

    func testParseStringWithSingleQuote() {
        let string = "'Bob'"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertEqual(jsvalue.string, "Bob")
    }
    
    func testParseStringWithEscapedQuote() {
        let string = "'Bob \"the man \" Roberts'"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertEqual(jsvalue.string, "Bob \"the man \" Roberts")
    }

    func testParseStringWithEscapedQuoteMatchingEndQuotes() {
        let string = "\"Bob \\\"the man\\\" Roberts\""
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertEqual(jsvalue.string, "Bob \"the man\" Roberts")
    }
    
    func testParseStringWithMultipleEscapes() {
        let string = "\"e&\\\\첊xz坍崦ݻ鍴\\\"嵥B3\u{000b}㢊\u{0015}L臯.샥\""
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertEqual(jsvalue.string, "e&\\첊xz坍崦ݻ鍴\"嵥B3\u{000b}㢊\u{0015}L臯.샥")
    }
    
    func testParseStringWithMultipleUnicodeTypes() {
        let string = "\"(\u{20da}g8큽튣>^Y{뤋.袊䂓;_g]S\u{202a}꽬L;^'#땏bႌ?C緡<䝲䲝断ꏏ6\u{001a}sD7IK5Wxo8\u{0006}p弊⼂ꯍ扵\u{0003}`뵂픋%ꄰ⫙됶l囏尛+䗅E쟇\\\\\""
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertEqual(jsvalue.string, "(\u{20da}g8큽튣>^Y{뤋.袊䂓;_g]S\u{202a}꽬L;^'#땏bႌ?C緡<䝲䲝断ꏏ6\u{001a}sD7IK5Wxo8\u{0006}p弊⼂ꯍ扵\u{0003}`뵂픋%ꄰ⫙됶l囏尛+䗅E쟇\\")
    }
    
    func testParseStringWithTrailingEscapedQuotes() {
        let string = "\"\\\"䬰ỐwD捾V`邀⠕VD㺝sH6[칑.:醥葹*뻵倻aD\\\"\""
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertEqual(jsvalue.string, "\"䬰ỐwD捾V`邀⠕VD㺝sH6[칑.:醥葹*뻵倻aD\"")
    }

    func testParseInteger() {
        let string = "101"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertTrue(jsvalue.number == 101)
    }

    func testParseNegativeInteger() {
        let string = "-109234"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertTrue(jsvalue.number == -109234)
    }
    
    func testParseDouble() {
        let string = "12.345678"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertEqualWithAccuracy(jsvalue!.number!, 12.345678, accuracy: 0.01)
    }
    
    func testParseNegativeDouble() {
        let string = "-123.949"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertEqualWithAccuracy(jsvalue!.number!, -123.949, accuracy: 0.01)
    }

    func testParseExponent() {
        let string = "12.345e2"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertEqualWithAccuracy(jsvalue!.number!, 12.345e2, accuracy: 0.01)
    }

    func testParsePositiveExponent() {
        let string = "12.345e+2"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertEqualWithAccuracy(jsvalue!.number!, 12.345e+2, accuracy: 0.01)
    }
    
    func testParseNegativeExponent() {
        let string = "-123.9492e-5"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertEqualWithAccuracy(jsvalue!.number!, -123.9492e-5, accuracy: 0.01)
    }

    func testParseEmptyArray() {
        let string = "[]"
        let json = try? JSON.parse(string)
        
        XCTAssertTrue(json != nil)
        if let json = json {
            XCTAssertTrue(json.array != nil)
        }
    }
    
    func testSingleElementArray() {
        let string = "[101]"
        let json = try? JSON.parse(string)
        
        XCTAssertTrue(json != nil)
        if let json = json {
            XCTAssertTrue(json.array != nil)
            XCTAssertTrue(json.array?.count == 1)
            XCTAssertTrue(json[0] == 101)
        }
    }

    func testMultipleElementArray() {
        let string = "[101, 202, 303]"
        let json = try? JSON.parse(string)
        
        XCTAssertTrue(json != nil)
        if let json = json {
            XCTAssertTrue(json.array != nil)
            XCTAssertTrue(json.array?.count == 3)
            XCTAssertTrue(json[0] == 101)
            XCTAssertTrue(json[1] == 202)
            XCTAssertTrue(json[2] == 303)
        }
    }
    
    func testParseEmptyDictionary() {
        let string = "{}"
        let json = try? JSON.parse(string)
        
        XCTAssertTrue(json != nil)
        if let json = json {
            XCTAssertTrue(json.object != nil)
        }
    }
    
    func testParseEmptyDictionaryWithExtraWhitespace() {
        let string = "         {\r\n\n\n\n     \t \t}   \t \t"
        let json = try? JSON.parse(string)
        
        XCTAssertTrue(json != nil)
        if let json = json {
            XCTAssertTrue(json.object != nil)
        }
    }
    
    func testParseDictionaryWithSingleKeyValuePair() {
        let string = "{ \"key\": 101 }"
        let json = try? JSON.parse(string)
        
        XCTAssertTrue(json != nil)
        if let json = json {
            XCTAssertTrue(json.object != nil)
            XCTAssertEqual(json["key"].number!, 101)
        }
    }
    
    func testParseDictionaryWithMultipleKeyValuePairs() {
        let string = "{ \"key1\": 101, \"key2\"    :           202,\"key3\":303}"
        let json = try? JSON.parse(string)
        
        XCTAssertTrue(json != nil)
        if let json = json {
            XCTAssertTrue(json.object != nil)
            XCTAssertEqual(json["key1"].number!, 101)
            XCTAssertEqual(json["key2"].number!, 202)
            XCTAssertEqual(json["key3"].number!, 303)
        }
    }
    
    func testParseMixedArray() {
        let string = "[1, -12, \"Bob\", true, false, null, -2.11234123]"
        let json = try? JSON.parse(string)
        
        XCTAssertTrue(json != nil)
        if let json = json {
            XCTAssertTrue(json.array != nil)
            XCTAssertEqual(json.array!.count, 7)
            XCTAssertEqual(json[0].number!, 1)
            XCTAssertEqual(json[1].number!, -12)
            XCTAssertEqual(json[2].string!, "Bob")
            XCTAssertEqual(json[3].bool!, true)
            XCTAssertEqual(json[4].bool!, false)
            XCTAssertEqual(json[5].null, true)
            XCTAssertEqualWithAccuracy(json[6].number!, -2.11234123, accuracy: 0.01)
        }
    }
    
    func testParseMixedDictionary() {
        let string = "{\"key1\": 1, \"key2\": -12, \"key3\": \"Bob\", \"key4\": true, \"key5\": false, \"key6\": null, \"key7\": -2.11234123}"
        let json = try? JSON.parse(string)
        
        XCTAssertTrue(json != nil)
        if let json = json {
            XCTAssertTrue(json.object != nil)
            XCTAssertEqual(json.object!.count, 7)
            XCTAssertEqual(json["key1"].number!, 1)
            XCTAssertEqual(json["key2"].number!, -12)
            XCTAssertEqual(json["key3"].string!, "Bob")
            XCTAssertEqual(json["key4"].bool!, true)
            XCTAssertEqual(json["key5"].bool!, false)
            XCTAssertEqual(json["key6"].null, true)
            XCTAssertEqualWithAccuracy(json["key7"].number!, -2.11234123, accuracy: 0.01)        }
    }
    
    func testParseNestedMixedTypes() {
        let string = "{\"key1\": 1, \"key2\": [        -12 , 12        ], \"key3\": \"Bob\", \"\\n鱿aK㝡␒㼙2촹f\": { 'foo': 'bar' }, \"key5\": false, \"key6\": null, \"key\\\"7\": -2.11234123}"
        let json = try? JSON.parse(string)
        
        XCTAssertTrue(json != nil)
        if let json = json {
            XCTAssertTrue(json.object != nil)
            XCTAssertEqual(json.object!.count, 7)
            XCTAssertEqual(json["key1"].number!, 1)
            XCTAssertTrue(json["key2"].array != nil)
            XCTAssertEqual(json["key2"].array!.count, 2)
            XCTAssertEqual(json["key2"][0].number!, -12)
            XCTAssertEqual(json["key2"][1].number!, 12)
            XCTAssertEqual(json["key3"].string!, "Bob")
            XCTAssertTrue(json["\n鱿aK㝡␒㼙2촹f"].object != nil)
            XCTAssertEqual(json["\n鱿aK㝡␒㼙2촹f"]["foo"].string!, "bar")
            XCTAssertEqual(json["key5"].bool!, false)
            XCTAssertEqual(json["key6"].null, true)
            XCTAssertEqualWithAccuracy(json["key\"7"].number!, -2.11234123, accuracy: 0.01)
        }
    }
    
    func testParsePrettyPrintedNestedMixedTypes() {
        let string = "{\"key1\": 1, \"key2\": [        -12 , 12        ], \"key3\": \"Bob\", \"\\n鱿aK㝡␒㼙2촹f\": { 'foo': 'bar' }, \"key5\": false, \"key6\": null, \"key\\\"7\": -2.11234123}"
        let json1 = try? JSON.parse(string)
        
        XCTAssertTrue(json1 != nil)
        
        let prettyPrinted = json1?.stringify() ?? ""
        let json2 = try? JSON.parse(prettyPrinted)
        XCTAssertEqual(json1, json2)
    }

    func testPrettyPrintedNestedObjectType() {
        let string = "{\"key\": { 'foo': 'bar' }}"
        let json1 = try? JSON.parse(string)

        XCTAssertTrue(json1 != nil)

        let prettyPrinted = json1?.stringify() ?? ""
        XCTAssertEqual(prettyPrinted, "{\n  \"key\": {\n    \"foo\": \"bar\"\n  }\n}")
    }

    func testPrettyPrintedNestedArrayType() {
        let string = "{\"key\": [ 'foo', 'bar' ]}"
        let json1 = try? JSON.parse(string)

        XCTAssertTrue(json1 != nil)

        let prettyPrinted = json1?.stringify() ?? ""
        XCTAssertEqual(prettyPrinted, "{\n  \"key\": [\n    \"foo\",\n    \"bar\"\n  ]\n}")
    }
    
    func testMutipleNestedArrayDictionaryTypes() {
        let string = "[[[[{},{},{\"ꫯ\":\"ꫯ\"}]]],[],[],[{}]]"
        let json = try? JSON.parse(string)

        XCTAssertTrue(json != nil)
    }
    
    func testParseStringWithSingleEscapedControlCharacters() {
        let string = "\"\\n\""
        let jsvalue = try? JSValue.parse(string)

        XCTAssertTrue(jsvalue != nil)
        XCTAssertEqual(jsvalue.string, "\n")
        
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let json: Any!
        do {
            json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
        } catch _ {
            json = nil
        };
        let jsonString = json as! String
        XCTAssertEqual("\n", jsonString)
    }
    
    func testParseStringWithEscapedControlCharacters() {
        let string = "\"\\\\\\/\\n\\r\\t\"" // "\\\/\n\r\t" => "\/\n\r\t"
        let jsvalue = try? JSValue.parse(string)
        
        XCTAssertTrue(jsvalue != nil)
        XCTAssertEqual(jsvalue.string, "\\/\n\r\t")
        
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let json: Any!
        do {
            json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
        } catch _ {
            json = nil
        };
        let jsonString = json as! String
        XCTAssertEqual(jsvalue.string, jsonString)
    }
    
    func testParseStringWithUnicodeEscapes() {
        let string = "\"value=\\u0026\\u03c6\\u00DF\""
        let jsvalue = try? JSValue.parse(string)
        XCTAssertTrue(jsvalue != nil)
        XCTAssertEqual(jsvalue.string, "value=&\u{03C6}ß")
    }

    func testParseStringWithInvalidUnicodeEscapes() {
        let string = "\"value=\\uxyz2\""
        let jsvalue = try? JSValue.parse(string)
        XCTAssertTrue(jsvalue == nil)
        // TODO: Validate the error information
    }

    func testParseStringWithSurrogatePairs() {
        let string = "\"\\uD834\\uDD1E\""
        let jsvalue = try? JSValue.parse(string)
        XCTAssertTrue(jsvalue != nil)
    }

    func testParseInvalidArrayMissingComma() {
        let string = "[1 true]"
        let jsvalue = try? JSValue.parse(string)
        XCTAssertTrue(jsvalue == nil)
    }

    func testParseInvalidArrayEmptyComma() {
        let string = "[1,,true]"
        let jsvalue = try? JSValue.parse(string)
        XCTAssertTrue(jsvalue == nil)
    }

    func testParseInvalidArrayTrailingComma() {
        let string = "[1,true,]"
        let jsvalue = try? JSValue.parse(string)
        XCTAssertTrue(jsvalue == nil)
    }

    func testParseStringUnescapedNewline() {
        let string = "[\"new\nline\"]"
        let jsvalue = try? JSValue.parse(string)
        XCTAssertTrue(jsvalue == nil)
    }

    func testParseStringEscapedNewline() {
        let string = "[\"new\\nline\"]"
        let jsvalue = try? JSValue.parse(string)
        XCTAssertTrue(jsvalue != nil)
    }

    func testParseStringUnescapedTab() {
        let string = "[\"new\tline\"]"
        let jsvalue = try? JSValue.parse(string)
        XCTAssertTrue(jsvalue == nil)
    }

    func testParseStringEscapedTab() {
        let string = "[\"new\\tline\"]"
        let jsvalue = try? JSValue.parse(string)
        XCTAssertTrue(jsvalue != nil)
    }

    // func testParseNumberNetIntStartingWithZero() {
    //     let string = "[-012]"
    //     let jsvalue = try? JSValue.parse(string)
    //     XCTAssertTrue(jsvalue == nil)
    // }

// TODO(owensd): This should be redone to support Linux as well.
#if os(macOS)
    func testParsingSampleJSON() {
        // SwiftBug(SR-4725) - Support test collateral properly
        let path = NSString.path(withComponents: [Bundle(for: JSValueParsingTests.self).bundlePath, "..", "..", "..", "TestCollateral", "sample.json"])
        XCTAssertNotNil(path)
        
        let string: NSString?
        do {
            string = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
        } catch _ {
            string = nil
        }
        XCTAssertNotNil(string)

        let json = try? JSON.parse(string! as String)
        XCTAssertTrue(json != nil)
    }
#endif
    
    func testStringifyEscaping() {
        let json: JSON = [
            "url" : "should escape double quotes \""
        ]
    
        let str = json.stringify(0)
        let expected = "{\"url\":\"should escape double quotes \\\"\"}"
        XCTAssertEqual(str, expected)
    }

    static let allTests = [
        ("testParseNull", testParseNull),
        ("testParseNullWithWhitespace", testParseNullWithWhitespace),
        ("testParseNullInvalidJSON", testParseNullInvalidJSON),
        ("testParseTrue", testParseTrue),
        ("testParseTrueWithWhitespace", testParseTrueWithWhitespace),
        ("testParseTrueInvalidJSON", testParseTrueInvalidJSON),
        ("testParseFalse", testParseFalse),
        ("testParseFalseWithWhitespace", testParseFalseWithWhitespace),
        ("testParseFalseInvalidJSON", testParseFalseInvalidJSON),
        ("testParseStringWithDoubleQuote", testParseStringWithDoubleQuote),
        ("testParseStringWithSingleQuote", testParseStringWithSingleQuote),
        ("testParseStringWithEscapedQuote", testParseStringWithEscapedQuote),
        ("testParseStringWithEscapedQuoteMatchingEndQuotes", testParseStringWithEscapedQuoteMatchingEndQuotes),
        ("testParseStringWithMultipleEscapes", testParseStringWithMultipleEscapes),
        ("testParseStringWithMultipleUnicodeTypes", testParseStringWithMultipleUnicodeTypes),
        ("testParseStringWithTrailingEscapedQuotes", testParseStringWithTrailingEscapedQuotes),
        ("testParseInteger", testParseInteger),
        ("testParseNegativeInteger", testParseNegativeInteger),
        ("testParseDouble", testParseDouble),
        ("testParseNegativeDouble", testParseNegativeDouble),
        ("testParseExponent", testParseExponent),
        ("testParsePositiveExponent", testParsePositiveExponent),
        ("testParseNegativeExponent", testParseNegativeExponent),
        ("testParseEmptyArray", testParseEmptyArray),
        ("testSingleElementArray", testSingleElementArray),
        ("testMultipleElementArray", testMultipleElementArray),
        ("testParseEmptyDictionary", testParseEmptyDictionary),
        ("testParseEmptyDictionaryWithExtraWhitespace", testParseEmptyDictionaryWithExtraWhitespace),
        ("testParseDictionaryWithSingleKeyValuePair", testParseDictionaryWithSingleKeyValuePair),
        ("testParseDictionaryWithMultipleKeyValuePairs", testParseDictionaryWithMultipleKeyValuePairs),
        ("testParseMixedArray", testParseMixedArray),
        ("testParseMixedDictionary", testParseMixedDictionary),
        ("testParseNestedMixedTypes", testParseNestedMixedTypes),
        ("testParsePrettyPrintedNestedMixedTypes", testParsePrettyPrintedNestedMixedTypes),
        ("testPrettyPrintedNestedObjectType", testPrettyPrintedNestedObjectType),
        ("testPrettyPrintedNestedArrayType", testPrettyPrintedNestedArrayType),
        ("testMutipleNestedArrayDictionaryTypes", testMutipleNestedArrayDictionaryTypes),
        ("testParseStringWithSingleEscapedControlCharacters", testParseStringWithSingleEscapedControlCharacters),
        ("testParseStringWithEscapedControlCharacters", testParseStringWithEscapedControlCharacters),
        ("testParseStringWithUnicodeEscapes", testParseStringWithUnicodeEscapes),
        ("testParseStringWithInvalidUnicodeEscapes", testParseStringWithInvalidUnicodeEscapes),
        ("testStringifyEscaping", testStringifyEscaping),
        ("testParseStringWithSurrogatePairs", testParseStringWithSurrogatePairs)
    ]
}
