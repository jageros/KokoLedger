import XCTest
@testable import KouKouLedger

final class PercentFormatterTests: XCTestCase {
    func testZeroPreviousAndZeroCurrentReturnsZero() {
        XCTAssertEqual(PercentFormatter.percentageDelta(current: 0, previous: 0), .zero)
    }

    func testZeroPreviousAndPositiveCurrentReturnsUnavailable() {
        XCTAssertEqual(PercentFormatter.percentageDelta(current: 100, previous: 0), .unavailable)
    }

    func testCurrentGreaterThanPreviousReturnsIncreased() {
        guard case let .increased(value) = PercentFormatter.percentageDelta(current: 150, previous: 100) else {
            return XCTFail("Expected increased delta.")
        }

        XCTAssertEqual(value, 50.0, accuracy: 0.001)
    }

    func testCurrentLessThanPreviousReturnsDecreased() {
        guard case let .decreased(value) = PercentFormatter.percentageDelta(current: 75, previous: 100) else {
            return XCTFail("Expected decreased delta.")
        }

        XCTAssertEqual(value, 25.0, accuracy: 0.001)
    }

    func testEqualCurrentAndPreviousReturnsUnchanged() {
        XCTAssertEqual(PercentFormatter.percentageDelta(current: 100, previous: 100), .unchanged)
    }

    func testFormatDeltaReturnsNonEmptyString() {
        XCTAssertFalse(PercentFormatter.formatDelta(.unavailable).isEmpty)
        XCTAssertFalse(PercentFormatter.formatDelta(.zero).isEmpty)
        XCTAssertFalse(PercentFormatter.formatDelta(.unchanged).isEmpty)
        XCTAssertFalse(PercentFormatter.formatDelta(.increased(12.3)).isEmpty)
        XCTAssertFalse(PercentFormatter.formatDelta(.decreased(8.5)).isEmpty)
    }
}
