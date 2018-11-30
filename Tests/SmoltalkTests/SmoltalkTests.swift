import XCTest
@testable import Smoltalk

final class SmoltalkTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Smoltalk().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
