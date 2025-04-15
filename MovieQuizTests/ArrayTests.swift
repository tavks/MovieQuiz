import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    private let array = [1, 1, 2, 3, 5]
    
    func testGetValueInRange() throws {
        let value = array[safe: 2]
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        let value = array[safe: 20]
        XCTAssertNil(value)
    }
}
