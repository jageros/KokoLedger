import Foundation

enum ValidationUtils {
    static func isValidEmail(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.range(
            of: #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#,
            options: [.regularExpression, .caseInsensitive]
        ) != nil
    }

    static func isValidPhone(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.range(of: #"^[0-9]{6,15}$"#, options: .regularExpression) != nil
    }

    static func isValidNickname(_ value: String) -> Bool {
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static func validateBookName(_ value: String) throws {
        try validateNonEmpty(value, maxLength: 40)
    }

    static func validateCategoryName(_ value: String) throws {
        try validateNonEmpty(value, maxLength: 20)
    }

    static func validateTransactionAmountMinor(_ value: Int64) throws {
        guard value > 0 else {
            throw AppError.validation
        }
    }

    private static func validateNonEmpty(_ value: String, maxLength: Int) throws {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= maxLength else {
            throw AppError.validation
        }
    }
}
