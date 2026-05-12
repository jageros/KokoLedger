import Foundation

enum CategoryRules {
    static func validateCategoryHierarchy(_ category: TransactionCategory) throws {
        switch category.level {
        case .level1:
            guard category.parentId == nil else {
                throw AppError.validation
            }
        case .level2:
            guard category.parentId != nil else {
                throw AppError.validation
            }
        }
    }

    static func validateChildCategory(parent: TransactionCategory, child: TransactionCategory) throws {
        guard parent.level == .level1 else {
            throw AppError.validation
        }

        guard child.level == .level2 else {
            throw AppError.validation
        }

        guard child.parentId == parent.id else {
            throw AppError.validation
        }

        guard child.type == parent.type else {
            throw AppError.validation
        }

        guard child.bookId == parent.bookId else {
            throw AppError.validation
        }
    }
}
