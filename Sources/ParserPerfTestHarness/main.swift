/*
 * Copyright (c) Kiad Studios, LLC. All rights reserved.
 * Licensed under the MIT License. See License in the project root for license information.
 */

import Foundation
import JSONLib
import QuartzCore

func printUsage() -> Never {
    print("usage: ParserPerfTestHarness [test file]")
    exit(-1)
}

struct Results<T>: CustomStringConvertible {
    let minimum: T
    let maximum: T
    let average: T

    var description: String {
        return "min: \(minimum), max: \(maximum), avg: \(average)"
    }
}

func memory(iterations: Int = 10, fn: @escaping () -> Void) -> Results<Int> {
    var min: Int = Int.max
    var max: Int = Int.min
    var counter: Int = 0

    for _ in 0..<iterations {
        let before = mstats()
        fn()
        let after = mstats()
        let used = after.bytes_used - before.bytes_used
        if used < min { min = used }
        if used > max { max = used }
        counter += used
    }

    return Results(minimum: min, maximum: max, average: Int(counter / iterations))
}

func performance(iterations: Int = 10, fn: () -> Void) -> Results<CFTimeInterval> {
    var min: CFTimeInterval = 999999999999
    var max: CFTimeInterval = 0
    var counter: CFTimeInterval = 0

    for _ in 0..<iterations {
        let before = CACurrentMediaTime()
        fn()
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

let filename = testFile.components(separatedBy: "/").last!
let shouldParse = filename.hasPrefix("y_")

let memoryResults = memory { let _ = JSON.parse(contents) }
let perfResults = performance { let _ = JSON.parse(contents) }

print("memory results: \(memoryResults.description)")
print("performance results: \(perfResults.description)")

print("baseline:")

let baselineMemoryResults = memory { let _ = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) }
let baselinePerfResults = performance { let _ = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) }

print("memory results: \(baselineMemoryResults.description)")
print("performance results: \(baselinePerfResults.description)")

let diffMemoryResults = Results(
    minimum: diff(memoryResults.minimum, baselineMemoryResults.minimum),
    maximum: diff(memoryResults.maximum, baselineMemoryResults.maximum),
    average: diff(memoryResults.average, baselineMemoryResults.average))
let diffPerfResults = Results(
    minimum: diff(perfResults.minimum, baselinePerfResults.minimum),
    maximum: diff(perfResults.maximum, baselinePerfResults.maximum),
    average: diff(perfResults.average, baselinePerfResults.average))

print("baseline difference:")
print("memory results: \(diffMemoryResults.description)")
print("performance results: \(diffPerfResults.description)")
