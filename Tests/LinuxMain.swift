/* --------------------------------------------------------------------------------------------
 * Copyright (c) Kiad Studios, LLC. All rights reserved.
 * Licensed under the MIT License. See License in the project root for license information.
 * ------------------------------------------------------------------------------------------ */

import XCTest
@testable import JSONLibTests

XCTMain([
    testCase(JSValueEquatableTests.allTests),
    testCase(JSValueIndexersTests.allTests),
    testCase(JSValueLiteralsTests.allTests),
    testCase(JSValueParsingTests.allTests),
])