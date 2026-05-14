import XCTest
@testable import KouKouLedger

@MainActor
final class TransactionFormViewModelTests: XCTestCase {
    func testDefaultTypeIsExpense() {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        let viewModel = TransactionFormViewModel(session: session, now: { ServiceTestSupport.referenceDate })

        XCTAssertEqual(viewModel.type, .expense)
    }

    func testAmount1234SavesAs1234MinorUnits() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let session = AppSession(dependencies: container)
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let viewModel = TransactionFormViewModel(session: session, now: { ServiceTestSupport.referenceDate })
        await viewModel.load()
        viewModel.amount = "12.34"
        viewModel.categoryLevel1Id = MockSeedData.expenseFoodCategoryId
        viewModel.categoryLevel2Id = MockSeedData.expenseCoffeeCategoryId

        let saved = await viewModel.save()

        XCTAssertTrue(saved)
        let transactions = try await container.transactionRepository.fetchTransactions(
            bookId: MockSeedData.primaryBookId,
            requestedBy: MockSeedData.defaultUserId,
            range: DateInterval(start: DateUtils.startOfToday(relativeTo: ServiceTestSupport.referenceDate), end: ServiceTestSupport.referenceDate)
        )
        XCTAssertTrue(transactions.contains { $0.amountMinor == 1234 })
    }

    func testInvalidAmountsCannotSave() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let emptyAmountViewModel = TransactionFormViewModel(session: session, now: { ServiceTestSupport.referenceDate })
        await emptyAmountViewModel.load()
        emptyAmountViewModel.categoryLevel1Id = MockSeedData.expenseFoodCategoryId
        emptyAmountViewModel.categoryLevel2Id = MockSeedData.expenseCoffeeCategoryId

        let emptySaved = await emptyAmountViewModel.save()

        XCTAssertFalse(emptySaved)

        let zeroAmountViewModel = TransactionFormViewModel(session: session, now: { ServiceTestSupport.referenceDate })
        await zeroAmountViewModel.load()
        zeroAmountViewModel.amount = "0"
        zeroAmountViewModel.categoryLevel1Id = MockSeedData.expenseFoodCategoryId
        zeroAmountViewModel.categoryLevel2Id = MockSeedData.expenseCoffeeCategoryId

        let zeroSaved = await zeroAmountViewModel.save()

        XCTAssertFalse(zeroSaved)
    }

    func testMissingCategoriesCannotSave() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let missingLevel1 = TransactionFormViewModel(session: session, now: { ServiceTestSupport.referenceDate })
        await missingLevel1.load()
        missingLevel1.amount = "10"
        missingLevel1.categoryLevel1Id = nil
        missingLevel1.categoryLevel2Id = MockSeedData.expenseCoffeeCategoryId

        let missingLevel1Saved = await missingLevel1.save()

        XCTAssertFalse(missingLevel1Saved)

        let missingLevel2 = TransactionFormViewModel(session: session, now: { ServiceTestSupport.referenceDate })
        await missingLevel2.load()
        missingLevel2.amount = "10"
        missingLevel2.categoryLevel1Id = MockSeedData.expenseFoodCategoryId
        missingLevel2.categoryLevel2Id = nil

        let missingLevel2Saved = await missingLevel2.save()

        XCTAssertFalse(missingLevel2Saved)
    }

    func testLevel2MustBelongToSelectedLevel1() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let viewModel = TransactionFormViewModel(session: session, now: { ServiceTestSupport.referenceDate })
        await viewModel.load()
        viewModel.amount = "10"
        viewModel.categoryLevel1Id = MockSeedData.expenseFoodCategoryId
        viewModel.categoryLevel2Id = MockSeedData.incomeBonusCategoryId

        let saved = await viewModel.save()

        XCTAssertFalse(saved)
    }

    func testCreateTransactionStoresCurrentBookAndCurrentUser() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let session = AppSession(dependencies: container)
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let viewModel = TransactionFormViewModel(session: session, now: { ServiceTestSupport.referenceDate })
        await viewModel.load()
        viewModel.amount = "8.88"
        viewModel.categoryLevel1Id = MockSeedData.expenseFoodCategoryId
        viewModel.categoryLevel2Id = MockSeedData.expenseCoffeeCategoryId

        let saved = await viewModel.save()

        XCTAssertTrue(saved)
        let transactions = try await container.transactionRepository.fetchTransactions(
            bookId: MockSeedData.primaryBookId,
            requestedBy: MockSeedData.defaultUserId,
            range: DateInterval(start: DateUtils.startOfToday(relativeTo: ServiceTestSupport.referenceDate), end: ServiceTestSupport.referenceDate)
        )
        let created = try XCTUnwrap(transactions.first { $0.amountMinor == 888 })
        XCTAssertEqual(created.bookId, MockSeedData.primaryBookId)
        XCTAssertEqual(created.createdBy, MockSeedData.defaultUserId)
    }

    func testEditorCanCreateAndReadonlyCannotCreate() async {
        let editorSession = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await editorSession.login(account: MockSeedData.editorEmail, password: MockSeedData.defaultPassword)
        let editorViewModel = TransactionFormViewModel(session: editorSession, now: { ServiceTestSupport.referenceDate })
        await editorViewModel.load()
        editorViewModel.amount = "6"
        editorViewModel.categoryLevel1Id = MockSeedData.expenseFoodCategoryId
        editorViewModel.categoryLevel2Id = MockSeedData.expenseCoffeeCategoryId

        let editorSaved = await editorViewModel.save()

        XCTAssertTrue(editorSaved)

        let readonlySession = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await readonlySession.login(account: MockSeedData.readonlyEmail, password: MockSeedData.defaultPassword)
        let readonlyViewModel = TransactionFormViewModel(session: readonlySession, now: { ServiceTestSupport.referenceDate })
        await readonlyViewModel.load()
        readonlyViewModel.amount = "6"
        readonlyViewModel.categoryLevel1Id = MockSeedData.expenseFoodCategoryId
        readonlyViewModel.categoryLevel2Id = MockSeedData.expenseCoffeeCategoryId

        let readonlySaved = await readonlyViewModel.save()

        XCTAssertFalse(readonlySaved)
    }

    func testEditTransactionSucceeds() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let session = AppSession(dependencies: container)
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let original = try await container.transactionRepository.createTransaction(
            bookId: MockSeedData.primaryBookId,
            type: .expense,
            amountMinor: 900,
            currencyCode: "CNY",
            categoryLevel1Id: MockSeedData.expenseFoodCategoryId,
            categoryLevel2Id: MockSeedData.expenseCoffeeCategoryId,
            occurredAt: ServiceTestSupport.referenceDate,
            note: "编辑前",
            createdBy: MockSeedData.defaultUserId
        )
        let viewModel = TransactionFormViewModel(session: session, transaction: original, now: { ServiceTestSupport.referenceDate })
        await viewModel.load()
        viewModel.amount = "11.11"
        viewModel.note = "编辑后"

        let saved = await viewModel.save()

        XCTAssertTrue(saved)
        let updated = try await container.transactionRepository.fetchTransaction(
            id: original.id,
            bookId: MockSeedData.primaryBookId,
            requestedBy: MockSeedData.defaultUserId
        )
        XCTAssertEqual(updated?.amountMinor, 1111)
        XCTAssertEqual(updated?.note, "编辑后")
    }

    func testDeleteTransactionSucceeds() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let session = AppSession(dependencies: container)
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let transaction = try await container.transactionRepository.createTransaction(
            bookId: MockSeedData.primaryBookId,
            type: .expense,
            amountMinor: 900,
            currencyCode: "CNY",
            categoryLevel1Id: MockSeedData.expenseFoodCategoryId,
            categoryLevel2Id: MockSeedData.expenseCoffeeCategoryId,
            occurredAt: ServiceTestSupport.referenceDate,
            note: "待删除",
            createdBy: MockSeedData.defaultUserId
        )
        let viewModel = TransactionFormViewModel(session: session, transaction: transaction, now: { ServiceTestSupport.referenceDate })

        let deleted = await viewModel.delete()

        XCTAssertTrue(deleted)
        let fetched = try await container.transactionRepository.fetchTransaction(
            id: transaction.id,
            bookId: MockSeedData.primaryBookId,
            requestedBy: MockSeedData.defaultUserId
        )
        XCTAssertNil(fetched)
    }
}
