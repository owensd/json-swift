/* --------------------------------------------------------------------------------------------
 * Copyright (c) Kiad Studios, LLC. All rights reserved.
 * Licensed under the MIT License. See License in the project root for license information.
 * ------------------------------------------------------------------------------------------ */

import XCTest
import JSONLib

/*
 * The purpose of these tests are to ensure the desired usage is maintained throughout all of the
 * refactoring that is taking place and will take place in the future.
 * 
 * Any breaks in these tests mean that usability of the API has been compromised.
 */

class JSValueUsageTests : XCTestCase {

    func testValidateSingleValueStringUsagePatternIfLet() {
        let json: JSValue = "Hello"
        if let value = json.string {
            XCTAssertEqual(value, "Hello")
        }
        else {
            XCTFail()
        }
    }
    
    func testValidateSingleValueStringUsagePatternOptionalChaining() {
        let json: JSValue = "Hello"
        
        let value = json.string?.uppercased() ?? ""
        XCTAssertEqual(value, "HELLO")
    }
    
    func testValidateSingleValueNumberUsagePatternIfLet() {
        let json: JSValue = 123
        if let value = json.number {
            XCTAssertEqual(value, 123)
        }
        else {
            XCTFail()
        }
    }
    
    func testValidateSingleValueNumberUsagePatternOptionalChaining() {
        let json: JSValue = 123
        
        let value = json.number?.distance(to: 100) ?? 0
        XCTAssertEqual(value, -23)
    }
    
    func testValidateSingleValueBoolUsagePatternIfLet() {
        let json: JSValue = false
        if let value = json.bool {
            XCTAssertEqual(value, false)
        }
        else {
            XCTFail()
        }
    }
    
    func testValidateSingleValueBoolUsagePatternOptionalChaining() {
        let json: JSValue = true
        
        let value = json.bool ?? false
        XCTAssertEqual(value, true)
    }

    
    func testValidateSingleLevelAccessInDictionaryUsage() {
        var json: JSValue = ["status": "ok"]
        
        XCTAssertEqual(json["status"].string, "ok")
    }

    func testValidateMultipleLevelAccessInDictionaryUsage() {
        var json: JSValue = ["item": ["info": ["name": "Item #1"]]]
        
        XCTAssertEqual(json["item"]["info"]["name"].string, "Item #1")
    }
    
    func testValidateMultipleLevelAccessInDictionaryUsageNonLiterals() {
        let item1 = "Item #1"
        
        var json: JSValue = ["item": ["info": ["name": JSValue(item1) ]]]
        
        XCTAssertEqual(json["item"]["info"]["name"].string, "Item #1")
    }
    
    func testValidateSingleLevelAccessInDictionaryUsageWithMissingKey() {
        var json: JSValue = ["status": "ok"]
        
        XCTAssertTrue(json["stat"].string == nil)
    }
    
    func testValidateArrayUsageNonLiterals() {
        var array = [JSValue]()
        array.append("Item #1")
        
        var json = JSValue(array)
        
        XCTAssertEqual(json[0].string, "Item #1")
    }

  /*
    func testFunctionalParsingToStruct() {
        var json: JSON = [
                "id" : 73,
                "name" : "Bloxus test",
                "needspassword" : true,
                "url" : "http://remote.bloxus.com/"
            ]
        
        let blog = make ⇒
            (json["id"].number ⇒ toInt) ⇒
            json["name"].string ⇒
            json["needspassword"].bool ⇒
            (json["url"].string ⇒ toURL)
        
        XCTAssertTrue(blog != nil)
        
        if let blog = blog {
            XCTAssertEqual(blog.id, 73)
            XCTAssertEqual(blog.name, "Bloxus test")
            XCTAssertEqual(blog.needsPassword, true)
            XCTAssertEqual(blog.url, URL(string: "http://remote.bloxus.com/")!)
        }
    }*/
    
    func testFunctionalParsingToStructIncorrectKey() {
        var json: JSON = [
            "id" : 73,
            "name" : "Bloxus test",
            "password" : true,
            "url" : "http://remote.bloxus.com/"
        ]
        
        let id = json["id"] ⇒ toInt
        let name = json["name"] ⇒ toString
        let password = json["needspassword"] ⇒ toBool
        let url = json["url"] ⇒ toURL
        
        _ = makeFailable ⇒ id ⇒ name ⇒ password ⇒ url
        
//        XCTAssertTrue(blog.1 != nil)
//        if let error = blog.1 {
//            XCTAssertEqual(error.code, JSValue.ErrorCode.KeyNotFound.code)
//        }
    }
    
    func testEnhancementRequest18() {
        var object: JSON = [:]
        object["one"] = 1
        
        var array: [JSON] = []
        for index in 1...10 {
            // nope... my stupid bug...
            array.append(JSON(int: index))
        }
        
        object["array"] = JSON(array)
        XCTAssertEqual(array.count, 10)
        
        var root: JSON = []
        root["object"] = object
    }

// Disabling these tests for now as they are not order deterministic.
//
//    func testStringifyWithDefaultIndent() {
//        var json: JSON = [
//            "id" : 73,
//            "name" : "Bloxus test",
//            "password" : true,
//            "url" : "http://remote.bloxus.com/"
//        ]
//        
//        let str = json.stringify()
//        let expected = "{\n  \"id\": 73.0,\n  \"password\": true,\n  \"name\": \"Bloxus test\",\n  \"url\": \"http://remote.bloxus.com/\"\n}"
//        XCTAssertEqual(str, expected)
//    }
//    
//    func testStringifyWithNoIndent() {
//        var json: JSON = [
//            "id" : 73,
//            "name" : "Bloxus test",
//            "password" : true,
//            "url" : "http://remote.bloxus.com/"
//        ]
//        
//        let str = json.stringify(0)
//        let expected = "{\"id\":73.0,\"password\":true,\"name\":\"Bloxus test\",\"url\":\"http://remote.bloxus.com/\"}"
//        XCTAssertEqual(str, expected)
//    }

   func testStringifyWithFlatPrintOut() {
       let json: JSON = [
           "id" : [
               "nested": [
                   "value": "hi"
               ]
           ]
       ]
       
       let str = json.stringify(nil)
       let expected = "{\"id\": {\"nested\": {\"value\": \"hi\"}}}"
       XCTAssertEqual(str, expected)
   }

    func testStringifyWithIntegerValue() {
       let json: JSON = [
           "id": 12
       ]
       
       let str = json.stringify(nil)
       let expected = "{\"id\": 12}"
       XCTAssertEqual(str, expected)
   }

    func testStringifyWithDoubleValue() {
       let json: JSON = [
           "id": 12.01
       ]
       
       let str = json.stringify(nil)
       let expected = "{\"id\": 12.01}"
       XCTAssertEqual(str, expected)
   }
}

// MARK: Test Helpers

struct Blog {
    let id: Int
    let name: String
    let needsPassword : Bool
    let url: URL
}

func toInt(_ number: Double?) -> Int? {
    if let value = number {
        return Int(value)
    }
    
    return nil
}

func toURL(_ string: String?) -> URL? {
    if let url = string {
        return URL(string: url)
    }
    
    return nil
}

func make(_ id: Int?)
    -> (String?)
    -> (Bool?)
    -> (URL?)
    -> Blog?
{
    return { name in
        return { needsPassword in
            return { url in
                if id == nil { return nil }
                if name == nil { return nil }
                if needsPassword == nil { return nil }
                if url == nil { return nil }
                
                return Blog(id: id!, name: name!, needsPassword: needsPassword!, url: url!)
            }
        }
    }
}

func makeFailable(_ id: Int?)
    -> (String?)
    -> (Bool?)
    -> (URL?)
    -> Blog?
{
    return { name in
        return { needsPassword in
            return { url in
                guard let id = id else { return nil }
                guard let name = name else { return nil }
                guard let needsPassword = needsPassword else { return nil }
                guard let url = url else { return nil }
                
                return Blog(id: id, name: name, needsPassword: needsPassword, url: url)
            }
        }
    }
}

func toInt(_ value: JSValue) -> Int? {
    if let value = value.number {
        return Int(value)
    }
    
    return nil
}

func toURL(_ value: JSValue) -> URL? {
    if let url = value.string {
        return URL(string: url)
    }
    
    return nil
}

func toBool(_ value: JSValue) -> Bool? {
    if let bool = value.bool {
        return bool
    }
    
    return nil
}

func toString(_ value: JSValue) -> String? {
    if let string = value.string {
        return string
    }
    
    return nil
}
