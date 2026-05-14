import XCTest
@testable import KouKouLedger

final class StatisticsServiceTests: XCTestCase {
    func testLedgerSummaryCalculatesIncomeExpenseAndBalance() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        let summary = try await container.statisticsService.ledgerSummary(
            bookId: MockSeedData.primaryBookId,
            requestedBy: MockSeedData.defaultUserId
        )

        XCTAssertGreaterThan(summary.totalIncomeMinor, 0)
        XCTAssertGreaterThan(summary.totalExpenseMinor, 0)
        XCTAssertEqual(summary.balanceMinor, summary.totalIncomeMinor - summary.totalExpenseMinor)
    }

    func testStatisticsSnapshotSupportsAllScopes() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        for scope in StatisticsTimeScope.allCases {
            let snapshot = try await container.statisticsService.statisticsSnapshot(
                bookId: MockSeedData.primaryBookId,
                scope: scope,
                relativeTo: ServiceTestSupport.referenceDate,
                requestedBy: MockSeedData.defaultUserId
            )

            XCTAssertEqual(snapshot.scope, scope)
            XCTAssertEqual(snapshot.netAssetMinor, snapshot.totalIncomeMinor - snapshot.totalExpenseMinor)
        }
    }

    func testLast7DaysSnapshotDataIsCorrect() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        let snapshot = try await container.statisticsService.statisticsSnapshot(
            bookId: MockSeedData.primaryBookId,
            scope: .last7Days,
            relativeTo: ServiceTestSupport.referenceDate,
            requestedBy: MockSeedData.defaultUserId
        )

        XCTAssertEqual(snapshot.totalIncomeMinor, 18_000_00)
        XCTAssertEqual(snapshot.totalExpenseMinor, 121_00)
        XCTAssertEqual(snapshot.netAssetMinor, 17_879_00)
        XCTAssertEqual(snapshot.averageDailyIncomeMinor, 18_000_00 / 7)
        XCTAssertEqual(snapshot.averageDailyExpenseMinor, 121_00 / 7)
    }

    func testThisMonthSnapshotDataIsCorrect() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let days = DateUtils.daysCount(in: DateUtils.thisMonthRange(relativeTo: ServiceTestSupport.referenceDate))

        let snapshot = try await container.statisticsService.statisticsSnapshot(
            bookId: MockSeedData.primaryBookId,
            scope: .thisMonth,
            relativeTo: ServiceTestSupport.referenceDate,
            requestedBy: MockSeedData.defaultUserId
        )

        XCTAssertEqual(snapshot.totalIncomeMinor, 18_000_00)
        XCTAssertEqual(snapshot.totalExpenseMinor, 121_00)
        XCTAssertEqual(snapshot.averageDailyIncomeMinor, 18_000_00 / Int64(days))
        XCTAssertEqual(snapshot.averageDailyExpenseMinor, 121_00 / Int64(days))
    }

    func testThisYearSnapshotDataIsCorrect() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let days = DateUtils.daysCount(in: DateUtils.thisYearRange(relativeTo: ServiceTestSupport.referenceDate))

        let snapshot = try await container.statisticsService.statisticsSnapshot(
            bookId: MockSeedData.primaryBookId,
            scope: .thisYear,
            relativeTo: ServiceTestSupport.referenceDate,
            requestedBy: MockSeedData.defaultUserId
        )

        XCTAssertEqual(snapshot.totalIncomeMinor, 18_000_00)
        XCTAssertEqual(snapshot.totalExpenseMinor, 121_00)
        XCTAssertEqual(snapshot.averageDailyIncomeMinor, 18_000_00 / Int64(days))
        XCTAssertEqual(snapshot.averageDailyExpenseMinor, 121_00 / Int64(days))
    }

    func testAllSnapshotUsesActualTransactionSpanAndUnavailableDeltas() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        container.store.transactions = [:]
        insertTransaction(
            amountMinor: 31_00,
            type: .income,
            occurredAt: ServiceTestSupport.referenceDate.addingTimeInterval(-86_400 * 30),
            container: container
        )
        insertTransaction(
            amountMinor: 62_00,
            type: .expense,
            occurredAt: ServiceTestSupport.referenceDate,
            container: container
        )

        let snapshot = try await container.statisticsService.statisticsSnapshot(
            bookId: MockSeedData.primaryBookId,
            scope: .all,
            relativeTo: ServiceTestSupport.referenceDate,
            requestedBy: MockSeedData.defaultUserId
        )

        XCTAssertEqual(snapshot.totalIncomeMinor, 31_00)
        XCTAssertEqual(snapshot.totalExpenseMinor, 62_00)
        XCTAssertEqual(snapshot.averageDailyIncomeMinor, 100)
        XCTAssertEqual(snapshot.averageDailyExpenseMinor, 200)
        XCTAssertEqual(snapshot.incomeDelta, .unavailable)
        XCTAssertEqual(snapshot.expenseDelta, .unavailable)
        XCTAssertEqual(snapshot.averageDailyIncomeDelta, .unavailable)
        XCTAssertEqual(snapshot.averageDailyExpenseDelta, .unavailable)
    }

    func testTrendPointsContainIncomeAndExpense() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        let points = try await container.statisticsService.trendPoints(
            bookId: MockSeedData.primaryBookId,
            scope: .last7Days,
            relativeTo: ServiceTestSupport.referenceDate,
            requestedBy: MockSeedData.defaultUserId
        )

        XCTAssertTrue(points.contains { $0.incomeMinor > 0 })
        XCTAssertTrue(points.contains { $0.expenseMinor > 0 })
    }

    func testCategoryRatioSlicesSupportLevel1AndLevel2() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        let level1 = try await container.statisticsService.categoryRatioSlices(
            bookId: MockSeedData.primaryBookId,
            scope: .thisYear,
            type: .expense,
            level: .level1,
            relativeTo: ServiceTestSupport.referenceDate,
            requestedBy: MockSeedData.defaultUserId
        )
        let level2 = try await container.statisticsService.categoryRatioSlices(
            bookId: MockSeedData.primaryBookId,
            scope: .thisYear,
            type: .expense,
            level: .level2,
            relativeTo: ServiceTestSupport.referenceDate,
            requestedBy: MockSeedData.defaultUserId
        )

        XCTAssertFalse(level1.isEmpty)
        XCTAssertFalse(level2.isEmpty)
        XCTAssertTrue(level1.allSatisfy { $0.amountMinor > 0 && $0.percentage > 0 })
    }

    func testDeletedTransactionsDoNotAffectStatistics() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let before = try await container.statisticsService.ledgerSummary(
            bookId: MockSeedData.primaryBookId,
            requestedBy: MockSeedData.defaultUserId
        )
        let categories = try await ServiceTestSupport.expenseCategoryPair(container: container)
        let transaction = try await container.transactionService.createTransaction(
            bookId: MockSeedData.primaryBookId,
            type: .expense,
            amountMinor: 999_999,
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

        let after = try await container.statisticsService.ledgerSummary(
            bookId: MockSeedData.primaryBookId,
            requestedBy: MockSeedData.defaultUserId
        )
        XCTAssertEqual(before, after)
    }

    func testTrendPointsDoNotIncludeDeletedTransactions() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let categories = try await ServiceTestSupport.expenseCategoryPair(container: container)
        let transaction = try await container.transactionService.createTransaction(
            bookId: MockSeedData.primaryBookId,
            type: .expense,
            amountMinor: 999_999,
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

        let points = try await container.statisticsService.trendPoints(
            bookId: MockSeedData.primaryBookId,
            scope: .last7Days,
            relativeTo: ServiceTestSupport.referenceDate,
            requestedBy: MockSeedData.defaultUserId
        )

        XCTAssertEqual(points.reduce(Int64(0)) { $0 + $1.expenseMinor }, 121_00)
        XCTAssertFalse(points.contains { $0.expenseMinor == 999_999 })
    }

    func testCategoryRatioSlicesIncomeAndExpenseAreCorrect() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        let incomeSlices = try await container.statisticsService.categoryRatioSlices(
            bookId: MockSeedData.primaryBookId,
            scope: .last7Days,
            type: .income,
            level: .level1,
            relativeTo: ServiceTestSupport.referenceDate,
            requestedBy: MockSeedData.defaultUserId
        )
        let expenseSlices = try await container.statisticsService.categoryRatioSlices(
            bookId: MockSeedData.primaryBookId,
            scope: .last7Days,
            type: .expense,
            level: .level1,
            relativeTo: ServiceTestSupport.referenceDate,
            requestedBy: MockSeedData.defaultUserId
        )

        XCTAssertEqual(incomeSlices.first?.categoryId, MockSeedData.incomeSalaryCategoryId)
        XCTAssertEqual(incomeSlices.first?.amountMinor, 18_000_00)
        XCTAssertEqual(incomeSlices.first?.percentage ?? 0, 100, accuracy: 0.001)
        XCTAssertEqual(expenseSlices.first?.categoryId, MockSeedData.expenseFoodCategoryId)
        XCTAssertEqual(expenseSlices.first?.amountMinor, 121_00)
        XCTAssertEqual(expenseSlices.first?.percentage ?? 0, 100, accuracy: 0.001)
    }

    func testCategoryRatioSlicesLevel1AndLevel2AreCorrect() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        let level1 = try await container.statisticsService.categoryRatioSlices(
            bookId: MockSeedData.primaryBookId,
            scope: .last7Days,
            type: .expense,
            level: .level1,
            relativeTo: ServiceTestSupport.referenceDate,
            requestedBy: MockSeedData.defaultUserId
        )
        let level2 = try await container.statisticsService.categoryRatioSlices(
            bookId: MockSeedData.primaryBookId,
            scope: .last7Days,
            type: .expense,
            level: .level2,
            relativeTo: ServiceTestSupport.referenceDate,
            requestedBy: MockSeedData.defaultUserId
        )

        XCTAssertEqual(level1.first?.categoryId, MockSeedData.expenseFoodCategoryId)
        XCTAssertEqual(level2.first?.categoryId, MockSeedData.expenseCoffeeCategoryId)
        XCTAssertEqual(level1.first?.amountMinor, 121_00)
        XCTAssertEqual(level2.first?.amountMinor, 121_00)
    }

    func testCategoryRatioPercentagesSumCloseTo100() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        let slices = try await container.statisticsService.categoryRatioSlices(
            bookId: MockSeedData.primaryBookId,
            scope: .last7Days,
            type: .expense,
            level: .level1,
            relativeTo: ServiceTestSupport.referenceDate,
            requestedBy: MockSeedData.defaultUserId
        )

        XCTAssertEqual(slices.reduce(0) { $0 + $1.percentage }, 100, accuracy: 0.001)
    }

    func testReadonlyCanViewStatisticsAndNonMemberCannot() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        _ = try await container.statisticsService.ledgerSummary(
            bookId: MockSeedData.primaryBookId,
            requestedBy: MockSeedData.readonlyUserId
        )

        await XCTAssertThrowsErrorAsync {
            _ = try await container.statisticsService.ledgerSummary(
                bookId: MockSeedData.primaryBookId,
                requestedBy: UUID()
            )
        }
    }

    private func insertTransaction(
        amountMinor: Int64,
        type: TransactionType,
        occurredAt: Date,
        container: AppDependencyContainer
    ) {
        let isIncome = type == .income
        let transaction = LedgerTransaction(
            id: UUID(),
            bookId: MockSeedData.primaryBookId,
            type: type,
            amountMinor: amountMinor,
            currencyCode: "CNY",
            categoryLevel1Id: isIncome ? MockSeedData.incomeSalaryCategoryId : MockSeedData.expenseFoodCategoryId,
            categoryLevel2Id: isIncome ? MockSeedData.incomeBonusCategoryId : MockSeedData.expenseCoffeeCategoryId,
            occurredAt: occurredAt,
            note: nil,
            createdBy: MockSeedData.defaultUserId,
            createdAt: occurredAt,
            updatedAt: occurredAt,
            deletedAt: nil
        )
        container.store.transactions[transaction.id] = transaction
    }
}
