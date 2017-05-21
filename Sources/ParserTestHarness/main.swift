/*
 * Copyright (c) Kiad Studios, LLC. All rights reserved.
 * Licensed under the MIT License. See License in the project root for license information.
 */

// This file is a test harness for validating that the parser returns a result or returns
// an error. This is a separate harness to guard against crashes.

import Foundation
import JSONLib

// Load this locally...
// import Freddy

func printUsage() -> Never {
    print("usage: ParserTestHarness [-freddy] -file:[test file]")
    exit(-1)
}

var useFreddy = false
var file: String? = nil

for arg in CommandLine.arguments {
    if arg == "-freddy" {
        useFreddy = true
    }
    else if arg.hasPrefix("-file") {
        file = arg.replacingOccurrences(of: "-file:", with: "")
    }
}

if let testFile = file {
    if FileManager.default.fileExists(atPath: testFile) == false {
        print("** file not found: \(testFile)")
        exit(-2)
    }

    let filename = testFile.components(separatedBy: "/").last!
    let shouldParse = filename.hasPrefix("y_")

    guard let data = try? Data(contentsOf: URL(fileURLWithPath: testFile)) else {
        if shouldParse {
            print("** unable to load the file at: \(testFile)")
            exit(-3)
        }
        else {
            print("expected failing parsing file: \(testFile)")
            exit(0)
        }
    }

    do {
        if useFreddy {
            // Must do this locally
            // let _ = try JSON(data: data)
            print("Must load Freddy locally")
            exit(-101)
        }
        else {
            let _ = try JSON.parse(data)
        }
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
        else {
            print("expected failing parsing file: \(testFile)")
        }
    }
}
else {
    printUsage()
}
