import XCTest
import JSONLib

class FailableTests: XCTestCase {

    func failsForNegativeNumbers(value: Int) -> Failable {
        if value >= 0 {
            return .Success
        }
        else {
            return .Failure(Error(code: value, domain: "failabletests", userInfo: nil))
        }
    }

    func doubleValueUnlessNegative(value: Int) -> FailableOf<Int> {
        if value >= 0 {
            return FailableOf<Int>(value * 2)
            // should be: return .Success(value * 2)
        }
        else {
            return .Failure(Error(code: value, domain: "failabletests", userInfo: ["Message" : "Pick a positive number"]))
        }
    }

    func testBasicFailableUsageSuccess() {
        let response = failsForNegativeNumbers(1)
        XCTAssertFalse(response.failed)
    }

    func testBasicFailableUsageFailure() {
        let response = failsForNegativeNumbers(-123)
        XCTAssertTrue(response.failed)

        let error = response.error!
        XCTAssertEqual(error.code, -123)
        XCTAssertEqual(error.domain, "failabletests")
        XCTAssertEqual(error.userInfo.count, 0)
    }

    func testBasicFailableOfUsageSuccess() {
        let response = doubleValueUnlessNegative(100)
        XCTAssertFalse(response.failed)
        XCTAssertEqual(response.value!, 200)
    }

    func testBasicFailableUsageOfFailure() {
        let response = doubleValueUnlessNegative(-13)
        XCTAssertTrue(response.failed)

        let error = response.error!
        XCTAssertEqual(error.code, -13)
        XCTAssertEqual(error.domain, "failabletests")
        XCTAssertEqual(error.userInfo.count, 1)
        XCTAssertTrue(error.userInfo["Message"]! as String == "Pick a positive number")
    }
    
    func testDelayedValuesInFailableOf() {
        var value: Int = 0
        var result = FailableOf(value++)
        
        XCTAssertEqual(result.value!, 0)
        XCTAssertEqual(result.value!, 0)
        XCTAssertEqual(value, 1)
    }

}
