//
//  JSON.usage.swift
//  JSON
//
//  Created by David Owens II on 8/11/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

import XCTest
import JSONLib

/*
 * The purpose of these tests are to ensure the desired usage is maintained throughout all of the
 * refactoring that is taking place and will take place in the future.
 * 
 * Any breaks in these tests mean that usability of the API has been compromised.
 */

extension JSValueTests {
    
    func testValidateSingleValueStringUsagePatternIfLet() {
        var json: JSValue = "Hello"
        if let value = json.string {
            XCTAssertEqual(value, "Hello")
        }
        else {
            XCTFail()
        }
    }
    
    func testValidateSingleValueStringUsagePatternOptionalChaining() {
        var json: JSValue = "Hello"
        
        let value = json.string?.uppercaseString ?? ""
        XCTAssertEqual(value, "HELLO")
    }
    
    func testValidateSingleValueNumberUsagePatternIfLet() {
        var json: JSValue = 123
        if let value = json.number {
            XCTAssertEqual(value, 123)
        }
        else {
            XCTFail()
        }
    }
    
    func testValidateSingleValueNumberUsagePatternOptionalChaining() {
        var json: JSValue = 123
        
        let value = json.number?.distanceTo(100) ?? 0
        XCTAssertEqual(value, -23)
    }
    
    func testValidateSingleValueBoolUsagePatternIfLet() {
        var json: JSValue = false
        if let value = json.bool {
            XCTAssertEqual(value, false)
        }
        else {
            XCTFail()
        }
    }
    
    func testValidateSingleValueBoolUsagePatternOptionalChaining() {
        var json: JSValue = true
        
        let value = json.bool?.boolValue ?? false
        XCTAssertEqual(value, true)
    }

    
    func testValidateSingleLevelAccessInDictionaryUsage() {
        var json: JSValue = ["status": "ok"]
        
        if let status = json["status"].string {
            XCTAssertEqual(status, "ok")
        }
        else {
            XCTFail()
        }
    }

    func testValidateMultipleLevelAccessInDictionaryUsage() {
        var json: JSValue = ["item": ["info": ["name": "Item #1"]]]
        
        if let name = json["item"]["info"]["name"].string {
            XCTAssertEqual(name, "Item #1")
        }
        else {
            XCTFail()
        }
    }
    
    func testValidateSingleLevelAccessInDictionaryUsageWithMissingKey() {
        var json: JSValue = ["status": "ok"]
        
        if let status = json["stat"].string {
            XCTFail()
        }
    }
    
    func testValidateMultipleLevelAccessInDictionaryUsageWithMissingKey() {
        var json: JSValue = ["item": ["info": ["description": "Item #1"]]]
        
        if let name = json["item"]["info"]["name"].string {
            XCTFail()
        }
    }
    
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
        
        XCTAssertTrue(blog.hasValue)
        
        if let blog = blog {
            XCTAssertEqual(blog.id, 73)
            XCTAssertEqual(blog.name, "Bloxus test")
            XCTAssertEqual(blog.needsPassword, true)
            XCTAssertEqual(blog.url, NSURL(string: "http://remote.bloxus.com/"))
        }
    }
    
    func testFunctionalParsingToStructIncorrectKey() {
        var json: JSON = [
            "id" : 73,
            "name" : "Bloxus test",
            "password" : true,
            "url" : "http://remote.bloxus.com/"
        ]
        
        let id: FailableOf<Int> = json["id"] ⇒ toIntFailable
        let name: FailableOf<String> = json["name"] ⇒ toStringFailable
        let password: FailableOf<Bool> = json["needspassword"] ⇒ toBoolFailable
        let url: FailableOf<NSURL> = json["url"] ⇒ toURLFailable
        
        let blog = makeFailable ⇒ id ⇒ name ⇒ password ⇒ url
        
        XCTAssertTrue(blog.failed)
        if let error = blog.error {
            XCTAssertEqual(error.code, JSValue.ErrorCode.KeyNotFound.code)
        }
    }
}

// MARK: Test Helpers

struct Blog {
    let id: Int
    let name: String
    let needsPassword : Bool
    let url: NSURL
}

func toInt(number: Double?) -> Int? {
    if let value = number {
        return Int(value)
    }
    
    return nil
}

func toURL(string: String?) -> NSURL? {
    if let url = string {
        return NSURL(string: url)
    }
    
    return nil
}

func make(id: Int?)
    (name: String?)
    (needsPassword: Bool?)
    (url: NSURL?) -> Blog?
{
    if id == nil { return nil }
    if name == nil { return nil }
    if needsPassword == nil { return nil }
    if url == nil { return nil }
    
    return Blog(id: id!, name: name!, needsPassword: needsPassword!, url: url!)
}

func makeFailable(id: FailableOf<Int>)
    (name: FailableOf<String>)
    (needsPassword: FailableOf<Bool>)
    (url: FailableOf<NSURL>) -> FailableOf<Blog>
{
    if let error = id.error { return FailableOf(error) }
    if let error = name.error { return FailableOf(error) }
    if let error = needsPassword.error { return FailableOf(error) }
    if let error = url.error { return FailableOf(error) }
    
    return FailableOf(Blog(id: id.value!, name: name.value!, needsPassword: needsPassword.value!, url: url.value!))
}

func toIntFailable(value: JSValue) -> FailableOf<Int> {
    if let value = value.number {
        return FailableOf(Int(value))
    }
    
    return FailableOf(value.error!)
}

func toURLFailable(value: JSValue) -> FailableOf<NSURL> {
    if let url = value.string {
        return FailableOf(NSURL(string: url))
    }
    
    return FailableOf(value.error!)
}

func toBoolFailable(value: JSValue) -> FailableOf<Bool> {
    if let bool = value.bool {
        return FailableOf(bool)
    }
    
    return FailableOf(value.error!)
}

func toStringFailable(value: JSValue) -> FailableOf<String> {
    if let string = value.string {
        return FailableOf(string)
    }
    
    return FailableOf(value.error!)
}
