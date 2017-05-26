/*
 * Copyright (c) Kiad Studios, LLC. All rights reserved.
 * Licensed under the MIT License. See License in the project root for license information.
 */

#if os(macOS)
import Foundation
import JSONLib
import QuartzCore

// Must load locally.
// import Freddy

func printUsage() -> Never {
    print("usage: ParserPerfTestHarness [test file]")
    exit(-1)
}

struct Results {
    let minimum: Double
    let maximum: Double
    let average: Double

    var description: String {
        let min = String(format: "%.3fms", minimum * 1000)
        let max = String(format: "%.3fms", maximum * 1000)
        let avg = String(format: "%.3fms", average * 1000)
        return "min: \(min), max: \(max), avg: \(avg)"
    }
}

func performance(iterations: Int = 1000, fn: () throws -> Void) throws -> Results {
    var min: CFTimeInterval = 999999999999
    var max: CFTimeInterval = 0
    var counter: CFTimeInterval = 0

    for _ in 0..<iterations {
        let before = CACurrentMediaTime()
        try fn()
        let after = CACurrentMediaTime()
        let used = after - before
        if used < min { min = used }
        if used > max { max = used }
        counter += used
    }

    return Results(minimum: min, maximum: max, average: counter / Double(iterations))
}

func diff(_ x: Int, _ y: Int) -> Int {
    return -100 * (x - y) / y
}

func diff(_ x: Double, _ y: Double) -> Double {
    return -100 * (x - y) / y
}


if CommandLine.arguments.count != 2 { printUsage() }
let testFile = CommandLine.arguments[1]
if FileManager.default.fileExists(atPath: testFile) == false {
    print("** file not found: \(testFile)")
    exit(-2)
}

guard let _contents = try? NSString(contentsOfFile: testFile, encoding: String.Encoding.utf8.rawValue) else {
    print("** unable to load the file at: \(testFile)")
    exit(-3)
}

let contents = _contents as String
let data = contents.data(using: .utf8)!
let bytes = [UInt8](data)

let filename = testFile.components(separatedBy: "/").last!
let shouldParse = filename.hasPrefix("y_")


print("NSJONSerialization:")
let nsjsonSerializationPerfResults = try performance { let _ = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) }
print("performance results: \(nsjsonSerializationPerfResults.description)")

print("\nJSONLib:")
let jsonlibPerfResults = try performance { let _ = try JSON.parse(data) }
print("performance results: \(jsonlibPerfResults.description)")

// Must enable locally.
// print("\nFreddy Results:")
// let freddyPerfResults = try performance { let _ = try? JSON(data: data) }
// print("performance results: \(freddyPerfResults.description)")
#else
print("Sadly, only macOS is supported for the perf infrastructure at this time.")
#endif