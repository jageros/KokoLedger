import XCTest
@testable import KouKouLedger

final class DateUtilsTests: XCTestCase {
    private let calendar = Calendar.autoupdatingCurrent

    func testLast7DaysRangeIncludesTodayAndStartsSixDaysAgo() throws {
        let date = try makeDate(year: 2026, month: 5, day: 12, hour: 15, minute: 30, second: 45)
        let range = DateUtils.last7DaysRange(relativeTo: date)
        let sixDaysAgo = try XCTUnwrap(calendar.date(byAdding: .day, value: -6, to: date))

        XCTAssertEqual(range.start, calendar.startOfDay(for: sixDaysAgo))
        XCTAssertEqual(range.end, date)
        XCTAssertLessThan(range.start, range.end)
    }

    func testThisMonthRangeStartsAtFirstDayOfMonth() throws {
        let date = try makeDate(year: 2026, month: 5, day: 12)
        let range = DateUtils.thisMonthRange(relativeTo: date)
        let expectedStart = try makeDate(year: 2026, month: 5, day: 1, hour: 0, minute: 0, second: 0)

        XCTAssertEqual(range.start, expectedStart)
        XCTAssertEqual(range.end, date)
    }

    func testThisYearRangeStartsAtFirstDayOfYear() throws {
        let date = try makeDate(year: 2026, month: 5, day: 12)
        let range = DateUtils.thisYearRange(relativeTo: date)
        let expectedStart = try makeDate(year: 2026, month: 1, day: 1, hour: 0, minute: 0, second: 0)

        XCTAssertEqual(range.start, expectedStart)
        XCTAssertEqual(range.end, date)
    }

    func testPreviousRangesExistForComparableScopes() throws {
        let date = try makeDate(year: 2026, month: 5, day: 12)

        XCTAssertNotNil(DateUtils.previousRange(for: .last7Days, relativeTo: date))
        XCTAssertNotNil(DateUtils.previousRange(for: .thisMonth, relativeTo: date))
        XCTAssertNotNil(DateUtils.previousRange(for: .thisYear, relativeTo: date))
    }

    func testAllTimeRangeIsNil() throws {
        let date = try makeDate(year: 2026, month: 5, day: 12)

        XCTAssertNil(DateUtils.range(for: .all, relativeTo: date))
    }

    func testDateMonthAndYearKeysAreStable() throws {
        let date = try makeDate(year: 2026, month: 5, day: 12)

        XCTAssertEqual(DateUtils.dateKey(date), "2026-05-12")
        XCTAssertEqual(DateUtils.monthKey(date), "2026-05")
        XCTAssertEqual(DateUtils.yearKey(date), "2026")
    }

    private func makeDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 15,
        minute: Int = 30,
        second: Int = 45
    ) throws -> Date {
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        return try XCTUnwrap(calendar.date(from: components))
    }
}
