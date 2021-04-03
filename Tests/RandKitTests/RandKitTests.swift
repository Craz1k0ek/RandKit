import XCTest
@testable import RandKit

final class RandKitTests: XCTestCase {
    func testExample() {
        XCTAssertTrue(true)
        var isaac = ISAAC()

        for _ in 0 ..< 256 {
            print(isaac.next())
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
