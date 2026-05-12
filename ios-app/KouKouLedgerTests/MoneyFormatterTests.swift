import XCTest
@testable import KouKouLedger

final class MoneyFormatterTests: XCTestCase {
    func testParsesDecimalAmountToMinorUnits() throws {
        XCTAssertEqual(try MoneyFormatter.parseAmountToMinor("12.34"), 1234)
    }

    func testParsesIntegerAmountToMinorUnits() throws {
        XCTAssertEqual(try MoneyFormatter.parseAmountToMinor("12"), 1200)
    }

    func testParsesSmallestMinorUnit() throws {
        XCTAssertEqual(try MoneyFormatter.parseAmountToMinor("0.01"), 1)
    }

    func testRejectsInvalidAmountInputs() {
        XCTAssertThrowsError(try MoneyFormatter.parseAmountToMinor(""))
        XCTAssertThrowsError(try MoneyFormatter.parseAmountToMinor("0"))
        XCTAssertThrowsError(try MoneyFormatter.parseAmountToMinor("-1"))
        XCTAssertThrowsError(try MoneyFormatter.parseAmountToMinor("12.345"))
        XCTAssertThrowsError(try MoneyFormatter.parseAmountToMinor("abc"))
    }

    func testConvertsMinorUnitsToDecimalString() {
        XCTAssertEqual(MoneyFormatter.minorToDecimalString(1234), "12.34")
        XCTAssertEqual(MoneyFormatter.minorToDecimalString(1), "0.01")
    }
}
