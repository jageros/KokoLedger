import XCTest
@testable import KouKouLedger

@MainActor
final class HomeViewModelTests: XCTestCase {
    func testLoadsTodayTransactions() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let viewModel = HomeViewModel(session: session, now: { ServiceTestSupport.referenceDate })

        await viewModel.load()

        XCTAssertEqual(viewModel.transactions.count, 1)
        XCTAssertEqual(viewModel.transactions.first?.note, "咖啡")
    }

    func testTodayIncomeExpenseAndBalanceAreCalculated() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let session = AppSession(dependencies: container)
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        _ = try await container.transactionRepository.createTransaction(
            bookId: MockSeedData.primaryBookId,
            type: .income,
            amountMinor: 20_00,
            currencyCode: "CNY",
            categoryLevel1Id: MockSeedData.incomeSalaryCategoryId,
            categoryLevel2Id: MockSeedData.incomeBonusCategoryId,
            occurredAt: ServiceTestSupport.referenceDate,
            note: "今日收入",
            createdBy: MockSeedData.defaultUserId
        )
        let viewModel = HomeViewModel(session: session, now: { ServiceTestSupport.referenceDate })

        await viewModel.load()

        XCTAssertEqual(viewModel.todayIncomeMinor, 20_00)
        XCTAssertEqual(viewModel.todayExpenseMinor, 32_00)
        XCTAssertEqual(viewModel.todayBalanceMinor, -12_00)
        XCTAssertEqual(viewModel.todayTransactionCount, 2)
    }

    func testReadonlyCannotCreateTransactions() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.readonlyEmail, password: MockSeedData.defaultPassword)
        let viewModel = HomeViewModel(session: session, now: { ServiceTestSupport.referenceDate })

        await viewModel.load()

        XCTAssertFalse(viewModel.canManageTransactions)
    }

    func testSwitchBookRefreshesHomeData() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let session = AppSession(dependencies: container)
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let secondBook = try await container.bookRepository.createBook(
            name: "旅行账本",
            note: nil,
            defaultCurrencyCode: "CNY",
            ownerId: MockSeedData.defaultUserId
        )
        let parent = try await container.categoryRepository.createLevel1Category(
            bookId: secondBook.id,
            name: "交通",
            type: .expense,
            icon: "tram",
            colorHex: "#007AFF",
            requestedBy: MockSeedData.defaultUserId
        )
        let child = try await container.categoryRepository.createLevel2Category(
            bookId: secondBook.id,
            parentId: parent.id,
            name: "地铁",
            icon: "tram.fill",
            colorHex: "#007AFF",
            requestedBy: MockSeedData.defaultUserId
        )
        _ = try await container.transactionRepository.createTransaction(
            bookId: secondBook.id,
            type: .expense,
            amountMinor: 600,
            currencyCode: "CNY",
            categoryLevel1Id: parent.id,
            categoryLevel2Id: child.id,
            occurredAt: ServiceTestSupport.referenceDate,
            note: "地铁票",
            createdBy: MockSeedData.defaultUserId
        )
        try await session.reloadBooks()
        try await session.selectBook(secondBook)
        let viewModel = HomeViewModel(session: session, now: { ServiceTestSupport.referenceDate })

        await viewModel.load()

        XCTAssertEqual(viewModel.transactions.count, 1)
        XCTAssertEqual(viewModel.transactions.first?.note, "地铁票")
        XCTAssertEqual(viewModel.todayExpenseMinor, 600)
    }
}
