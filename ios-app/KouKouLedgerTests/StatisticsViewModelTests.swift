import XCTest
@testable import KouKouLedger

@MainActor
final class StatisticsViewModelTests: XCTestCase {
    func testDefaults() async throws {
        let session = try await makeLoggedInSession()
        let service = StatisticsServiceSpy()
        let viewModel = StatisticsViewModel(
            session: session,
            statisticsRepository: StatisticsRepository(service: service),
            now: { ServiceTestSupport.referenceDate }
        )

        XCTAssertEqual(viewModel.selectedScope, .last7Days)
        XCTAssertEqual(viewModel.selectedChartDisplayType, .line)
        XCTAssertEqual(viewModel.selectedCategoryTransactionType, .expense)
        XCTAssertEqual(viewModel.selectedCategoryLevel, .level1)
    }

    func testChangingScopeRefreshesAllStatistics() async throws {
        let session = try await makeLoggedInSession()
        let service = StatisticsServiceSpy()
        let viewModel = StatisticsViewModel(
            session: session,
            statisticsRepository: StatisticsRepository(service: service),
            now: { ServiceTestSupport.referenceDate }
        )

        await viewModel.load()
        XCTAssertEqual(service.snapshotCalls, 1)
        XCTAssertEqual(service.trendCalls, 1)
        XCTAssertEqual(service.categoryRatioCalls, 1)

        await viewModel.selectScope(.thisMonth)

        XCTAssertEqual(viewModel.selectedScope, .thisMonth)
        XCTAssertEqual(viewModel.snapshot?.scope, .thisMonth)
        XCTAssertEqual(service.snapshotCalls, 2)
        XCTAssertEqual(service.trendCalls, 2)
        XCTAssertEqual(service.categoryRatioCalls, 2)
    }

    func testChangingChartDisplayTypeDoesNotReloadStatistics() async throws {
        let session = try await makeLoggedInSession()
        let service = StatisticsServiceSpy()
        let viewModel = StatisticsViewModel(
            session: session,
            statisticsRepository: StatisticsRepository(service: service),
            now: { ServiceTestSupport.referenceDate }
        )

        await viewModel.load()
        viewModel.selectChartDisplayType(.bar)

        XCTAssertEqual(viewModel.selectedChartDisplayType, .bar)
        XCTAssertEqual(service.snapshotCalls, 1)
        XCTAssertEqual(service.trendCalls, 1)
        XCTAssertEqual(service.categoryRatioCalls, 1)
    }

    func testChangingCategoryTypeRefreshesOnlyCategoryRatioSlices() async throws {
        let session = try await makeLoggedInSession()
        let service = StatisticsServiceSpy()
        let viewModel = StatisticsViewModel(
            session: session,
            statisticsRepository: StatisticsRepository(service: service),
            now: { ServiceTestSupport.referenceDate }
        )

        await viewModel.load()
        await viewModel.selectCategoryTransactionType(.income)

        XCTAssertEqual(viewModel.selectedCategoryTransactionType, .income)
        XCTAssertEqual(service.snapshotCalls, 1)
        XCTAssertEqual(service.trendCalls, 1)
        XCTAssertEqual(service.categoryRatioCalls, 2)
        XCTAssertEqual(service.lastCategoryType, .income)
    }

    func testChangingCategoryLevelRefreshesOnlyCategoryRatioSlices() async throws {
        let session = try await makeLoggedInSession()
        let service = StatisticsServiceSpy()
        let viewModel = StatisticsViewModel(
            session: session,
            statisticsRepository: StatisticsRepository(service: service),
            now: { ServiceTestSupport.referenceDate }
        )

        await viewModel.load()
        await viewModel.selectCategoryLevel(.level2)

        XCTAssertEqual(viewModel.selectedCategoryLevel, .level2)
        XCTAssertEqual(service.snapshotCalls, 1)
        XCTAssertEqual(service.trendCalls, 1)
        XCTAssertEqual(service.categoryRatioCalls, 2)
        XCTAssertEqual(service.lastCategoryLevel, .level2)
    }

    func testReadonlyCanLoadStatistics() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let session = AppSession(dependencies: container)
        try await session.login(account: MockSeedData.readonlyEmail, password: MockSeedData.defaultPassword)
        let viewModel = StatisticsViewModel(session: session, now: { ServiceTestSupport.referenceDate })

        await viewModel.load()

        XCTAssertNotNil(viewModel.snapshot)
        XCTAssertFalse(viewModel.trendPoints.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testNonMemberCannotLoadStatistics() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let book = try XCTUnwrap(container.store.book(id: MockSeedData.primaryBookId))
        let session = AppSession(dependencies: container)
        try await session.register(
            nickname: "非成员",
            email: "outsider@koukou.local",
            phone: nil,
            password: MockSeedData.defaultPassword
        )
        await session.setCurrentBook(book)
        let viewModel = StatisticsViewModel(session: session, now: { ServiceTestSupport.referenceDate })

        await viewModel.load()

        XCTAssertNil(viewModel.snapshot)
        XCTAssertTrue(viewModel.trendPoints.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    private func makeLoggedInSession() async throws -> AppSession {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let session = AppSession(dependencies: container)
        try await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        return session
    }
}

private final class StatisticsServiceSpy: StatisticsServiceProtocol {
    var snapshotCalls = 0
    var trendCalls = 0
    var categoryRatioCalls = 0
    var lastCategoryType: TransactionType?
    var lastCategoryLevel: CategoryLevel?

    func ledgerSummary(bookId: UUID, requestedBy userId: UUID) async throws -> LedgerSummary {
        LedgerSummary(totalIncomeMinor: 0, totalExpenseMinor: 0, currencyCode: "CNY")
    }

    func statisticsSnapshot(
        bookId: UUID,
        scope: StatisticsTimeScope,
        relativeTo date: Date,
        requestedBy userId: UUID
    ) async throws -> StatisticsSnapshot {
        snapshotCalls += 1
        return StatisticsSnapshot(
            scope: scope,
            totalIncomeMinor: 12_00,
            incomeDelta: .unchanged,
            totalExpenseMinor: 8_00,
            expenseDelta: .unchanged,
            averageDailyIncomeMinor: 2_00,
            averageDailyIncomeDelta: .unchanged,
            averageDailyExpenseMinor: 1_00,
            averageDailyExpenseDelta: .unchanged,
            currencyCode: "CNY"
        )
    }

    func trendPoints(
        bookId: UUID,
        scope: StatisticsTimeScope,
        relativeTo date: Date,
        requestedBy userId: UUID
    ) async throws -> [TrendPoint] {
        trendCalls += 1
        return [
            TrendPoint(id: UUID(), date: date, incomeMinor: 12_00, expenseMinor: 8_00)
        ]
    }

    func categoryRatioSlices(
        bookId: UUID,
        scope: StatisticsTimeScope,
        type: TransactionType,
        level: CategoryLevel,
        relativeTo date: Date,
        requestedBy userId: UUID
    ) async throws -> [CategoryRatioSlice] {
        categoryRatioCalls += 1
        lastCategoryType = type
        lastCategoryLevel = level
        return [
            CategoryRatioSlice(
                id: UUID(),
                categoryId: UUID(),
                categoryName: "测试分类",
                amountMinor: 8_00,
                percentage: 100
            )
        ]
    }
}
