import XCTest
@testable import KouKouLedger

final class BookServiceTests: XCTestCase {
    func testUserCanFetchAccessibleBooks() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        let books = try await container.bookService.fetchBooks(for: MockSeedData.defaultUserId)

        XCTAssertFalse(books.isEmpty)
        XCTAssertTrue(books.contains { $0.id == MockSeedData.primaryBookId })
    }

    func testCreateBookMakesRequesterOwner() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        let book = try await container.bookService.createBook(
            name: "旅行账本",
            note: nil,
            defaultCurrencyCode: "CNY",
            ownerId: MockSeedData.defaultUserId
        )

        XCTAssertEqual(book.ownerId, MockSeedData.defaultUserId)
    }

    func testOwnerCanUpdateBook() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let book = try XCTUnwrap(
            try await container.bookService.fetchBook(
                id: MockSeedData.primaryBookId,
                userId: MockSeedData.defaultUserId
            )
        )
        let updated = Book(
            id: book.id,
            name: "更新后的账本",
            note: book.note,
            defaultCurrencyCode: book.defaultCurrencyCode,
            ownerId: book.ownerId,
            createdAt: book.createdAt,
            updatedAt: book.updatedAt,
            archivedAt: book.archivedAt
        )

        let result = try await container.bookService.updateBook(updated, requestedBy: MockSeedData.defaultUserId)

        XCTAssertEqual(result.name, "更新后的账本")
    }

    func testEditorCannotUpdateBookSettings() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let book = try XCTUnwrap(
            try await container.bookService.fetchBook(
                id: MockSeedData.primaryBookId,
                userId: MockSeedData.editorUserId
            )
        )

        await XCTAssertThrowsErrorAsync {
            _ = try await container.bookService.updateBook(book, requestedBy: MockSeedData.editorUserId)
        }
    }

    func testReadonlyCannotUpdateBookSettings() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let book = try XCTUnwrap(
            try await container.bookService.fetchBook(
                id: MockSeedData.primaryBookId,
                userId: MockSeedData.readonlyUserId
            )
        )

        await XCTAssertThrowsErrorAsync {
            _ = try await container.bookService.updateBook(book, requestedBy: MockSeedData.readonlyUserId)
        }
    }
}
