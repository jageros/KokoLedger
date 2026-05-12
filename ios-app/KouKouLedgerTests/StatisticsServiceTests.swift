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
}
