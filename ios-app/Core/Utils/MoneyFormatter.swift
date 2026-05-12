import Foundation

enum MoneyFormatter {
    static func format(amountMinor: Int64, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: decimalNumber(from: amountMinor))
            ?? "\(currencyCode) \(minorToDecimalString(amountMinor))"
    }

    static func formatCompact(amountMinor: Int64, currencyCode: String) -> String {
        "\(currencyCode) \(minorToDecimalString(amountMinor))"
    }

    static func parseAmountToMinor(_ input: String) throws -> Int64 {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AppError.validation
        }

        guard trimmed.range(of: #"^[0-9]+(\.[0-9]{1,2})?$"#, options: .regularExpression) != nil else {
            throw AppError.validation
        }

        let parts = trimmed.split(separator: ".", omittingEmptySubsequences: false)
        guard let major = Int64(parts[0]) else {
            throw AppError.validation
        }

        let minor: Int64
        if parts.count == 2 {
            let rawMinor = String(parts[1])
            let paddedMinor = rawMinor.padding(toLength: 2, withPad: "0", startingAt: 0)
            guard let parsedMinor = Int64(paddedMinor) else {
                throw AppError.validation
            }
            minor = parsedMinor
        } else {
            minor = 0
        }

        let multiplied = major.multipliedReportingOverflow(by: 100)
        guard !multiplied.overflow else {
            throw AppError.validation
        }

        let total = multiplied.partialValue.addingReportingOverflow(minor)
        guard !total.overflow, total.partialValue > 0 else {
            throw AppError.validation
        }

        return total.partialValue
    }

    static func minorToDecimalString(_ amountMinor: Int64) -> String {
        let isNegative = amountMinor < 0
        let magnitude = amountMinor.magnitude
        let major = magnitude / 100
        let minor = magnitude % 100
        let sign = isNegative ? "-" : ""
        return "\(sign)\(major).\(String(format: "%02llu", minor))"
    }

    private static func decimalNumber(from amountMinor: Int64) -> NSDecimalNumber {
        NSDecimalNumber(
            mantissa: amountMinor.magnitude,
            exponent: -2,
            isNegative: amountMinor < 0
        )
    }
}
