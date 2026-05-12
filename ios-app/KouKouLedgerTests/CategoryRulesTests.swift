import XCTest
@testable import KouKouLedger

final class CategoryRulesTests: XCTestCase {
    func testLevel1WithoutParentIsValid() {
        let category = makeCategory(level: .level1, parentId: nil)

        XCTAssertNoThrow(try CategoryRules.validateCategoryHierarchy(category))
    }

    func testLevel1WithParentThrows() {
        let category = makeCategory(level: .level1, parentId: UUID())

        XCTAssertThrowsError(try CategoryRules.validateCategoryHierarchy(category))
    }

    func testLevel2WithParentIsValid() {
        let category = makeCategory(level: .level2, parentId: UUID())

        XCTAssertNoThrow(try CategoryRules.validateCategoryHierarchy(category))
    }

    func testLevel2WithoutParentThrows() {
        let category = makeCategory(level: .level2, parentId: nil)

        XCTAssertThrowsError(try CategoryRules.validateCategoryHierarchy(category))
    }

    func testChildCategoryWithDifferentTypeThrows() {
        let parent = makeCategory(level: .level1, parentId: nil, type: .expense)
        let child = makeCategory(level: .level2, parentId: parent.id, type: .income, bookId: parent.bookId)

        XCTAssertThrowsError(try CategoryRules.validateChildCategory(parent: parent, child: child))
    }

    func testChildCategoryWithDifferentBookThrows() {
        let parent = makeCategory(level: .level1, parentId: nil, type: .expense)
        let child = makeCategory(level: .level2, parentId: parent.id, type: .expense, bookId: UUID())

        XCTAssertThrowsError(try CategoryRules.validateChildCategory(parent: parent, child: child))
    }

    private func makeCategory(
        level: CategoryLevel,
        parentId: UUID?,
        type: TransactionType = .expense,
        bookId: UUID = UUID()
    ) -> TransactionCategory {
        TransactionCategory(
            id: UUID(),
            bookId: bookId,
            name: "餐饮",
            type: type,
            level: level,
            parentId: parentId,
            icon: nil,
            colorHex: nil,
            sortOrder: 0,
            isArchived: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
