/* --------------------------------------------------------------------------------------------
 * Copyright (c) Kiad Studios, LLC. All rights reserved.
 * Licensed under the MIT License. See License in the project root for license information.
 * ------------------------------------------------------------------------------------------ */

import Foundation
import XCTest
import JSONLib
import Swift

class JSValuePerformanceTests: XCTestCase {
    
    func baseline(_ name: String) {
        let path = Bundle(for: JSValuePerformanceTests.self).path(forResource: name, ofType: "json")
        XCTAssertNotNil(path)
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
        XCTAssertNotNil(data)
        
        self.measure() {
            let json: Any!
            do {
                json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            } catch _ {
                json = nil
            }
            XCTAssertTrue(json != nil)
        }
    }
    
    func library(_ name: String) {
        let path = Bundle(for: JSValuePerformanceTests.self).path(forResource: name, ofType: "json")
        XCTAssertNotNil(path)
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
        XCTAssertNotNil(data)
        
        self.measure() {
            let json = JSON.parse(data)
            XCTAssertTrue(json.1 == nil)
        }
    }
    
//    func testSampleBaseline() {
//        baseline("sample")
//    }
//    
//    func testSampleLib() {
//        library("sample")
//    }
//
//    func testSmallBaseline() {
//        baseline("small-dict")
//    }
//
//    func testSmallLib() {
//        library("small-dict")
//    }
    
//    func testMediumBaseline() {
//        baseline("medium-dict")
//    }
//    
//    func testMediumLib() {
//        library("medium-dict")
//    }
//
//    func testLargeBaseline() {
//        baseline("large-dict")
//    }
//    
//    func testLargeLib() {
//        library("large-dict")
//    }

}
