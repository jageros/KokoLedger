import Foundation

enum PercentFormatter {
    static func percentageDelta(current: Int64, previous: Int64) -> PercentageDelta {
        if previous == 0 {
            return current == 0 ? .zero : .unavailable
        }

        if current > previous {
            return .increased(Double(current - previous) / Double(previous) * 100)
        }

        if current < previous {
            return .decreased(Double(previous - current) / Double(previous) * 100)
        }

        return .unchanged
    }

    static func formatDelta(_ delta: PercentageDelta) -> String {
        switch delta {
        case .unavailable:
            "—"
        case .zero:
            "0%"
        case let .increased(value):
            "增长 \(formatPercentage(value))"
        case let .decreased(value):
            "下降 \(formatPercentage(value))"
        case .unchanged:
            "持平"
        }
    }

    static func formatPercentage(_ value: Double) -> String {
        if value == 0 {
            return "0%"
        }

        return String(format: "%.1f%%", value)
    }
}
