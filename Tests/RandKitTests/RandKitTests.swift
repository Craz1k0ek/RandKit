import XCTest
@testable import RandKit

final class RandKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RandKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
