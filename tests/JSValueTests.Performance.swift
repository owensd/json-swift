//
//  JSValueTests.Performance.swift
//  JSON
//
//  Created by David Owens II on 8/15/14.
//  Copyright (c) 2014 David Owens II. All rights reserved.
//

import Cocoa
import XCTest
import JSONLib
import Swift

class JSValuePerformanceTests: XCTestCase {
    
    func baseline(name: String) {
        let path = NSBundle(forClass: JSValuePerformanceTests.self).pathForResource(name, ofType: "json")
        XCTAssertNotNil(path)
        
        let data = NSData(contentsOfFile: path!)!
        XCTAssertNotNil(data)
        
        self.measureBlock() {
            let json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
            XCTAssertTrue(json != nil)
        }
    }
    
    func library(name: String) {
        let path = NSBundle(forClass: JSValuePerformanceTests.self).pathForResource(name, ofType: "json")
        XCTAssertNotNil(path)
        
        let data = NSData(contentsOfFile: path!)!
        XCTAssertNotNil(data)
        
        self.measureBlock() {
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
