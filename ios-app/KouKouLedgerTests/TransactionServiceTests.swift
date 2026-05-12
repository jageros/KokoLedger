import XCTest
@testable import KouKouLedger

final class TransactionServiceTests: XCTestCase {
    func testOwnerAndEditorCanCreateTransaction() async throws {
        let ownerContainer = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let ownerCategories = try await ServiceTestSupport.expenseCategoryPair(container: ownerContainer)
        let ownerTransaction = try await ownerContainer.transactionService.createTransaction(
            bookId: MockSeedData.primaryBookId,
            type: .expense,
            amountMinor: 1200,
            currencyCode: "CNY",
            categoryLevel1Id: ownerCategories.parent.id,
            categoryLevel2Id: ownerCategories.child.id,
            occurredAt: ServiceTestSupport.referenceDate,
            note: nil,
            createdBy: MockSeedData.defaultUserId
        )
        XCTAssertEqual(ownerTransaction.createdBy, MockSeedData.defaultUserId)

        let editorContainer = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let editorCategories = try await ServiceTestSupport.expenseCategoryPair(container: editorContainer)
        let editorTransaction = try await editorContainer.transactionService.createTransaction(
            bookId: MockSeedData.primaryBookId,
            type: .expense,
            amountMinor: 1500,
            currencyCode: "CNY",
            categoryLevel1Id: editorCategories.parent.id,
            categoryLevel2Id: editorCategories.child.id,
            occurredAt: ServiceTestSupport.referenceDate,
            note: nil,
            createdBy: MockSeedData.editorUserId
        )
        XCTAssertEqual(editorTransaction.createdBy, MockSeedData.editorUserId)
    }

    func testReadonlyCannotCreateTransaction() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let categories = try await ServiceTestSupport.expenseCategoryPair(container: container)

        await XCTAssertThrowsErrorAsync {
            _ = try await container.transactionService.createTransaction(
                bookId: MockSeedData.primaryBookId,
                type: .expense,
                amountMinor: 1200,
                currencyCode: "CNY",
                categoryLevel1Id: categories.parent.id,
                categoryLevel2Id: categories.child.id,
                occurredAt: ServiceTestSupport.referenceDate,
                note: nil,
                createdBy: MockSeedData.readonlyUserId
            )
        }
    }

    func testInvalidTransactionInputsThrow() async throws {
        let amountContainer = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let categories = try await ServiceTestSupport.expenseCategoryPair(container: amountContainer)
        await XCTAssertThrowsErrorAsync {
            _ = try await amountContainer.transactionService.createTransaction(
                bookId: MockSeedData.primaryBookId,
                type: .expense,
                amountMinor: 0,
                currencyCode: "CNY",
                categoryLevel1Id: categories.parent.id,
                categoryLevel2Id: categories.child.id,
                occurredAt: ServiceTestSupport.referenceDate,
                note: nil,
                createdBy: MockSeedData.defaultUserId
            )
        }

        let mismatchContainer = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let mismatch = try await ServiceTestSupport.mismatchedCategoryPair(container: mismatchContainer)
        await XCTAssertThrowsErrorAsync {
            _ = try await mismatchContainer.transactionService.createTransaction(
                bookId: MockSeedData.primaryBookId,
                type: .expense,
                amountMinor: 1200,
                currencyCode: "CNY",
                categoryLevel1Id: mismatch.parent.id,
                categoryLevel2Id: mismatch.child.id,
                occurredAt: ServiceTestSupport.referenceDate,
                note: nil,
                createdBy: MockSeedData.defaultUserId
            )
        }
    }

    func testDeleteTransactionSoftDeletesAndExcludesFromFetch() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let categories = try await ServiceTestSupport.expenseCategoryPair(container: container)
        let transaction = try await container.transactionService.createTransaction(
            bookId: MockSeedData.primaryBookId,
            type: .expense,
            amountMinor: 1200,
            currencyCode: "CNY",
            categoryLevel1Id: categories.parent.id,
            categoryLevel2Id: categories.child.id,
            occurredAt: ServiceTestSupport.referenceDate,
            note: nil,
            createdBy: MockSeedData.defaultUserId
        )

        try await container.transactionService.deleteTransaction(
            id: transaction.id,
            bookId: MockSeedData.primaryBookId,
            requestedBy: MockSeedData.defaultUserId
        )

        XCTAssertNil(try await container.transactionService.fetchTransaction(
            id: transaction.id,
            bookId: MockSeedData.primaryBookId,
            requestedBy: MockSeedData.defaultUserId
        ))
    }
}
