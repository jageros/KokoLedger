import Foundation

enum DateUtils {
    private static var calendar: Calendar {
        .autoupdatingCurrent
    }

    static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    static func endOfDay(_ date: Date) -> Date {
        guard let dayInterval = calendar.dateInterval(of: .day, for: date) else {
            return date
        }

        return dayInterval.end.addingTimeInterval(-1)
    }

    static func startOfToday(relativeTo date: Date) -> Date {
        startOfDay(date)
    }

    static func startOfYesterday(relativeTo date: Date) -> Date {
        let todayStart = startOfToday(relativeTo: date)
        return calendar.date(byAdding: .day, value: -1, to: todayStart) ?? todayStart
    }

    static func endOfYesterdayComparable(relativeTo date: Date) -> Date {
        calendar.date(byAdding: .day, value: -1, to: date) ?? startOfYesterday(relativeTo: date)
    }

    static func last7DaysRange(relativeTo date: Date) -> DateInterval {
        let startReference = calendar.date(byAdding: .day, value: -6, to: date) ?? date
        return safeInterval(start: startOfDay(startReference), end: date)
    }

    static func previousLast7DaysRange(relativeTo date: Date) -> DateInterval {
        let currentRange = last7DaysRange(relativeTo: date)
        let end = currentRange.start
        let start = end.addingTimeInterval(-currentRange.duration)
        return safeInterval(start: start, end: end)
    }

    static func thisMonthRange(relativeTo date: Date) -> DateInterval {
        let start = calendar.dateInterval(of: .month, for: date)?.start ?? startOfDay(date)
        return safeInterval(start: start, end: date)
    }

    static func previousMonthComparableRange(relativeTo date: Date) -> DateInterval {
        let currentMonthStart = thisMonthRange(relativeTo: date).start
        let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart)
            ?? currentMonthStart

        let currentComponents = calendar.dateComponents([.day, .hour, .minute, .second, .nanosecond], from: date)
        let maxPreviousMonthDay = calendar.range(of: .day, in: .month, for: previousMonthStart)?.count
            ?? max(currentComponents.day ?? 1, 1)
        let comparableDay = min(max(currentComponents.day ?? 1, 1), maxPreviousMonthDay)

        var endComponents = calendar.dateComponents([.year, .month], from: previousMonthStart)
        endComponents.day = comparableDay
        endComponents.hour = currentComponents.hour
        endComponents.minute = currentComponents.minute
        endComponents.second = currentComponents.second
        endComponents.nanosecond = currentComponents.nanosecond

        let end = calendar.date(from: endComponents)
            ?? calendar.dateInterval(of: .month, for: previousMonthStart)?.end.addingTimeInterval(-1)
            ?? previousMonthStart

        return safeInterval(start: previousMonthStart, end: end)
    }

    static func thisYearRange(relativeTo date: Date) -> DateInterval {
        let start = calendar.dateInterval(of: .year, for: date)?.start ?? startOfDay(date)
        return safeInterval(start: start, end: date)
    }

    static func previousYearComparableRange(relativeTo date: Date) -> DateInterval {
        let currentYearStart = thisYearRange(relativeTo: date).start
        let previousYearStart = calendar.date(byAdding: .year, value: -1, to: currentYearStart)
            ?? currentYearStart

        let currentComponents = calendar.dateComponents(
            [.month, .day, .hour, .minute, .second, .nanosecond],
            from: date
        )
        let previousYear = calendar.component(.year, from: previousYearStart)
        let comparableMonth = currentComponents.month ?? 1

        var monthStartComponents = DateComponents()
        monthStartComponents.calendar = calendar
        monthStartComponents.timeZone = calendar.timeZone
        monthStartComponents.year = previousYear
        monthStartComponents.month = comparableMonth
        monthStartComponents.day = 1

        let monthStart = calendar.date(from: monthStartComponents) ?? previousYearStart
        let maxComparableDay = calendar.range(of: .day, in: .month, for: monthStart)?.count
            ?? max(currentComponents.day ?? 1, 1)
        let comparableDay = min(max(currentComponents.day ?? 1, 1), maxComparableDay)

        var endComponents = DateComponents()
        endComponents.calendar = calendar
        endComponents.timeZone = calendar.timeZone
        endComponents.year = previousYear
        endComponents.month = comparableMonth
        endComponents.day = comparableDay
        endComponents.hour = currentComponents.hour
        endComponents.minute = currentComponents.minute
        endComponents.second = currentComponents.second
        endComponents.nanosecond = currentComponents.nanosecond

        let end = calendar.date(from: endComponents)
            ?? calendar.dateInterval(of: .year, for: previousYearStart)?.end.addingTimeInterval(-1)
            ?? previousYearStart

        return safeInterval(start: previousYearStart, end: end)
    }

    static func allTimeRange() -> DateInterval? {
        nil
    }

    static func range(for scope: StatisticsTimeScope, relativeTo date: Date) -> DateInterval? {
        switch scope {
        case .last7Days:
            last7DaysRange(relativeTo: date)
        case .thisMonth:
            thisMonthRange(relativeTo: date)
        case .thisYear:
            thisYearRange(relativeTo: date)
        case .all:
            allTimeRange()
        }
    }

    static func previousRange(for scope: StatisticsTimeScope, relativeTo date: Date) -> DateInterval? {
        switch scope {
        case .last7Days:
            previousLast7DaysRange(relativeTo: date)
        case .thisMonth:
            previousMonthComparableRange(relativeTo: date)
        case .thisYear:
            previousYearComparableRange(relativeTo: date)
        case .all:
            nil
        }
    }

    static func daysCount(in interval: DateInterval) -> Int {
        let start = startOfDay(interval.start)
        let end = startOfDay(interval.end)
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return max(days + 1, 1)
    }

    static func daysElapsedInCurrentMonth(relativeTo date: Date) -> Int {
        max(calendar.component(.day, from: date), 1)
    }

    static func daysElapsedInCurrentYear(relativeTo date: Date) -> Int {
        max(calendar.ordinality(of: .day, in: .year, for: date) ?? 1, 1)
    }

    static func dateKey(_ date: Date) -> String {
        format(date, dateFormat: "yyyy-MM-dd")
    }

    static func monthKey(_ date: Date) -> String {
        format(date, dateFormat: "yyyy-MM")
    }

    static func yearKey(_ date: Date) -> String {
        format(date, dateFormat: "yyyy")
    }

    private static func safeInterval(start: Date, end: Date) -> DateInterval {
        if start < end {
            return DateInterval(start: start, end: end)
        }

        return DateInterval(start: start, end: start.addingTimeInterval(1))
    }

    private static func format(_ date: Date, dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }
}
