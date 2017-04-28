/* --------------------------------------------------------------------------------------------
 * Copyright (c) Kiad Studios, LLC. All rights reserved.
 * Licensed under the MIT License. See License in the project root for license information.
 * ------------------------------------------------------------------------------------------ */

import XCTest
import JSONLib

class JSValueEquatableTests : XCTestCase {

    func testEquatableNullTrue() {
        let lhs: JSON = nil
        let rhs: JSON = nil
        
        XCTAssertEqual(lhs, rhs)
    }
    
    func testEquatableBoolTrue() {
        let lhs: JSValue = true
        let rhs: JSValue = true
        
        XCTAssertEqual(lhs, rhs)
    }
    
    func testEquatableBoolFalse() {
        let lhs: JSValue = true
        let rhs: JSValue = false
        
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testEquatableStringTrue() {
        let lhs: JSValue = "hello"
        let rhs: JSValue = "hello"
        
        XCTAssertEqual(lhs, rhs)
    }
    
    func testEquatableStringFalse() {
        let lhs: JSValue = "hello"
        let rhs: JSValue = "bob"
        
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testEquatableNumberTrue() {
        let lhs: JSValue = 1234
        let rhs: JSValue = 1234
        
        XCTAssertEqual(lhs, rhs)
    }
    
    func testEquatableNumberFalse() {
        let lhs: JSValue = 1234
        let rhs: JSValue = 4321
        
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testEquatableArrayTrue() {
        let lhs: JSValue = [1, 3, 5]
        let rhs: JSValue = [1, 3, 5]
        
        XCTAssertEqual(lhs, rhs)
    }
    
    func testEquatableArrayFalse() {
        let lhs: JSValue = [1, 3, 5]
        let rhs: JSValue = [1, 3, 7]
        
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testEquatableObjectTrue() {
        let lhs: JSValue = ["key1": 1, "key2": 3, "key3": 5]
        let rhs: JSValue = ["key1": 1, "key2": 3, "key3": 5]
        
        XCTAssertEqual(lhs, rhs)
    }
    
    func testEquatableObjectFalse() {
        let lhs: JSValue = ["key1": 1, "key2": 3, "key3": 5]
        let rhs: JSValue = ["key0": 1, "key1": 3, "key2": 5]
        
        XCTAssertNotEqual(lhs, rhs)
    }
    
    func testEquatableTypeMismatch() {
        let lhs: JSValue = ["key1": 1, "key2": 3, "key3": 5]
        let rhs: JSValue = [1, 3, 5]
        
        XCTAssertNotEqual(lhs, rhs)
    }
}
