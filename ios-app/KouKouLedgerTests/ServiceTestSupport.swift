import XCTest
@testable import KouKouLedger

enum ServiceTestSupport {
    static let referenceDate = Date(timeIntervalSince1970: 1_779_350_400)

    static func expenseCategoryPair(
        container: AppDependencyContainer
    ) async throws -> (parent: TransactionCategory, child: TransactionCategory) {
        let categories = try await container.categoryService.fetchCategories(
            bookId: MockSeedData.primaryBookId,
            type: .expense,
            includeArchived: false,
            requestedBy: MockSeedData.defaultUserId
        )
        let parent = try XCTUnwrap(categories.first { $0.level == .level1 })
        let child = try XCTUnwrap(categories.first { $0.parentId == parent.id })
        return (parent, child)
    }

    static func mismatchedCategoryPair(
        container: AppDependencyContainer
    ) async throws -> (parent: TransactionCategory, child: TransactionCategory) {
        let categories = try await container.categoryService.fetchCategories(
            bookId: MockSeedData.primaryBookId,
            type: nil,
            includeArchived: false,
            requestedBy: MockSeedData.defaultUserId
        )
        let parent = try XCTUnwrap(categories.first { $0.level == .level1 && $0.type == .expense })
        let child = try XCTUnwrap(categories.first { $0.level == .level2 && $0.type == .income })
        return (parent, child)
    }
}

func XCTAssertThrowsErrorAsync(
    _ expression: @escaping () async throws -> Void,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        try await expression()
        XCTFail("Expected expression to throw.", file: file, line: line)
    } catch {
        // Expected.
    }
}
