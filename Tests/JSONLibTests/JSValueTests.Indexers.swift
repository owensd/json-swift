/* --------------------------------------------------------------------------------------------
 * Copyright (c) Kiad Studios, LLC. All rights reserved.
 * Licensed under the MIT License. See License in the project root for license information.
 * ------------------------------------------------------------------------------------------ */

import XCTest
import JSONLib

class JSValueIndexersTests : XCTestCase {

    func testBasicArrayMutability() {
        var value: JSON = [1, "Dog", 3.412, true]
        XCTAssertTrue(value[0].number == 1)
        XCTAssertTrue(value[1].string == "Dog")
        XCTAssertTrue(value[2].number == 3.412)
        XCTAssertTrue(value[3].bool == true)
        
        let newValue: JSValue = "Cat"
        value[1] = newValue
        XCTAssertTrue(value[0].number == 1)
        XCTAssertTrue(value[1].string == "Cat")
        XCTAssertTrue(value[2].number == 3.412)
        XCTAssertTrue(value[3].bool == true)

        value[1] = "Mouse"
        XCTAssertTrue(value[0].number == 1)
        XCTAssertTrue(value[1].string == "Mouse")
        XCTAssertTrue(value[2].number == 3.412)
        XCTAssertTrue(value[3].bool == true)
    }
    
    func testNestedArray() {
        var value: JSON = [1, "Dog", [3.412, true]]
        XCTAssertTrue(value[0].number == 1)
        XCTAssertTrue(value[1].string == "Dog")

        value[2][0] = 1.123
        XCTAssertTrue(value[2][0].number == 1.123)
        XCTAssertTrue(value[2][1].bool == true)
    }
    
    func testNestedMixedTypes() {
        var json: JSON = [
            "stat": "ok",
            "blogs": [
                "blog": [
                    [
                        "id": 73,
                        "name": "Bloxus test",
                        "needspassword": true,
                        "url": "http://remote.bloxus.com/"
                    ],
                    [
                        "id": 74,
                        "name": "Manila Test",
                        "needspassword": false,
                        "url": "http://flickrtest1.userland.com/"
                    ]
                ]
            ]
        ]
        
        XCTAssertTrue(json["stat"].string == "ok")
        XCTAssertTrue(json["blogs"]["blog"][0]["id"].number == 73)
        XCTAssertTrue(json["blogs"]["blog"][0]["needspassword"].bool == true)
        
        json["blogs"]["blog"][0]["needspassword"] = false
        XCTAssertTrue(json["stat"].string == "ok")
        XCTAssertTrue(json["blogs"]["blog"][0]["id"].number == 73)
        XCTAssertTrue(json["blogs"]["blog"][0]["needspassword"].bool == false)
    }

    static let allTests = [
        ("testBasicArrayMutability", testBasicArrayMutability),
        ("testNestedArray", testNestedArray),
        ("testNestedMixedTypes", testNestedMixedTypes),
    ]

}
