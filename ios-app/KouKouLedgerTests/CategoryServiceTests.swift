import XCTest
@testable import KouKouLedger

final class CategoryServiceTests: XCTestCase {
    func testOwnerAndEditorCanCreateLevel1Category() async throws {
        let ownerContainer = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let ownerCategory = try await ownerContainer.categoryService.createLevel1Category(
            bookId: MockSeedData.primaryBookId,
            name: "宠物",
            type: .expense,
            icon: nil,
            colorHex: nil,
            requestedBy: MockSeedData.defaultUserId
        )
        XCTAssertEqual(ownerCategory.level, .level1)

        let editorContainer = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let editorCategory = try await editorContainer.categoryService.createLevel1Category(
            bookId: MockSeedData.primaryBookId,
            name: "报销",
            type: .income,
            icon: nil,
            colorHex: nil,
            requestedBy: MockSeedData.editorUserId
        )
        XCTAssertEqual(editorCategory.level, .level1)
    }

    func testReadonlyCannotCreateCategory() async {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        await XCTAssertThrowsErrorAsync {
            _ = try await container.categoryService.createLevel1Category(
                bookId: MockSeedData.primaryBookId,
                name: "宠物",
                type: .expense,
                icon: nil,
                colorHex: nil,
                requestedBy: MockSeedData.readonlyUserId
            )
        }
    }

    func testCreateLevel2CategoryUsesParent() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let parent = try await expenseLevel1Category(container: container)

        let child = try await container.categoryService.createLevel2Category(
            bookId: MockSeedData.primaryBookId,
            parentId: parent.id,
            name: "咖啡",
            icon: nil,
            colorHex: nil,
            requestedBy: MockSeedData.defaultUserId
        )

        XCTAssertEqual(child.parentId, parent.id)
        XCTAssertEqual(child.type, parent.type)
    }

    func testArchiveCategoryMarksItArchived() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let parent = try await expenseLevel1Category(container: container)

        try await container.categoryService.archiveCategory(
            categoryId: parent.id,
            bookId: MockSeedData.primaryBookId,
            requestedBy: MockSeedData.defaultUserId
        )

        let categories = try await container.categoryService.fetchCategories(
            bookId: MockSeedData.primaryBookId,
            type: .expense,
            includeArchived: true,
            requestedBy: MockSeedData.defaultUserId
        )
        XCTAssertTrue(categories.first { $0.id == parent.id }?.isArchived == true)
    }

    private func expenseLevel1Category(container: AppDependencyContainer) async throws -> TransactionCategory {
        let categories = try await container.categoryService.fetchCategories(
            bookId: MockSeedData.primaryBookId,
            type: .expense,
            includeArchived: false,
            requestedBy: MockSeedData.defaultUserId
        )
        return try XCTUnwrap(categories.first { $0.level == .level1 })
    }
}
