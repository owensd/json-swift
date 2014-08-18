//
//  JSValueTests.Performance.swift
//  JSON
//
//  Created by David Owens II on 8/15/14.
//  Copyright (c) 2014 Kiad Software. All rights reserved.
//

import Cocoa
import XCTest
import JSONLib
import Swift

class JSValuePerformanceTests: XCTestCase {

    func testSamplesJSONJSONLib() {
        let path = NSBundle(forClass: JSValuePerformanceTests.self).pathForResource("sample", ofType: "json")
        XCTAssertNotNil(path)
        
        let string: String = NSString.stringWithContentsOfFile(path!, encoding: NSUTF8StringEncoding, error: nil)
        XCTAssertNotNil(string)
        
        self.measureBlock() {
            let json = JSON.parse(string)
            XCTAssertFalse(json.failed)
        }
    }

    func testSampleJSONNSJSONSerialization() {
        let path = NSBundle(forClass: JSValuePerformanceTests.self).pathForResource("sample", ofType: "json")
        XCTAssertNotNil(path)
        
        let string = NSString.stringWithContentsOfFile(path!, encoding: NSUTF8StringEncoding, error: nil)
        XCTAssertNotNil(string)
        
        self.measureBlock() {
            let data = string.dataUsingEncoding(NSUTF8StringEncoding)
            XCTAssertNotNil(data)
            
            let json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
            XCTAssertTrue(json != nil)
        }
    }

}
