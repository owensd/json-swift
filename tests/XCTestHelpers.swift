//
//  XCTestHelpers.swift
//  ParseKit
//
//  Created by David Owens on 6/18/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

import XCTest

func XCTAssertNotNil<T>(value: T?, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    if value == nil { XCTFail(message) }
}

func XCTAssertDoesNotThrow<T>(@autoclosure fn: () throws -> T, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    do {
        try fn()
    }
    catch {
        XCTFail(message, file: file, line: line)
    }
}

func XCTAssertDoesThrow<T>(@autoclosure fn: () throws -> T, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    do {
        try fn()
        XCTFail(message, file: file, line: line)
    }
    catch {
    }
}

func XCTAssertDoesThrowErrorOfType<T>(@autoclosure fn: () throws -> T, message: String = "Error thrown was of an unexpected type.",
    type: MirrorType, file: String = __FILE__, line: UInt = __LINE__)
{
    do {
        try fn()
        XCTFail(message, file: file, line: line)
    }
    catch {
        if reflect(error).summary != type.summary {
            XCTFail(message, file: file, line: line)
        }
    }
}
