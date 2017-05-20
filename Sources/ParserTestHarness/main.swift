/*
 * Copyright (c) Kiad Studios, LLC. All rights reserved.
 * Licensed under the MIT License. See License in the project root for license information.
 */

// This file is a test harness for validating that the parser returns a result or returns
// an error. This is a separate harness to guard against crashes.

import Foundation
import JSONLib

func printUsage() -> Never {
    print("usage: ParserTestHarness [test file]")
    exit(-1)
}

if CommandLine.arguments.count != 2 { printUsage() }
let testFile = CommandLine.arguments[1]
if FileManager.default.fileExists(atPath: testFile) == false {
    print("** file not found: \(testFile)")
    exit(-2)
}

guard let contents = try? NSString(contentsOfFile: testFile, encoding: String.Encoding.utf8.rawValue) else {
    print("** unable to load the file at: \(testFile)")
    exit(-3)
}

let filename = testFile.components(separatedBy: "/").last!
let shouldParse = filename.hasPrefix("y_")
do {
    let json = try JSON.parse(contents as String)
    if shouldParse {
        print("success parsing file: \(testFile)")
    }
    else {
        print("** expected error while parsing file: \(testFile)")
        exit(-5)
    }
}
catch {
    if shouldParse {
        print("** error parsing file: \(testFile)")
        print("--- ERROR INFO ---")
        print("\(error)")
        print("------------------")
        exit(-4)
    }
}