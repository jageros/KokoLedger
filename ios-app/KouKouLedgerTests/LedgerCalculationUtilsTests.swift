import XCTest
@testable import KouKouLedger

final class LedgerCalculationUtilsTests: XCTestCase {
    func testTotalIncomeMinorOnlyCountsActiveIncome() {
        let transactions = [
            makeTransaction(type: .income, amountMinor: 1000),
            makeTransaction(type: .expense, amountMinor: 200),
            makeTransaction(type: .income, amountMinor: 500, deletedAt: Date())
        ]

        XCTAssertEqual(LedgerCalculationUtils.totalIncomeMinor(transactions: transactions), 1000)
    }

    func testTotalExpenseMinorOnlyCountsActiveExpense() {
        let transactions = [
            makeTransaction(type: .income, amountMinor: 1000),
            makeTransaction(type: .expense, amountMinor: 200),
            makeTransaction(type: .expense, amountMinor: 300, deletedAt: Date())
        ]

        XCTAssertEqual(LedgerCalculationUtils.totalExpenseMinor(transactions: transactions), 200)
    }

    func testBalanceMinorEqualsIncomeMinusExpense() {
        let transactions = [
            makeTransaction(type: .income, amountMinor: 1000),
            makeTransaction(type: .expense, amountMinor: 250)
        ]

        XCTAssertEqual(LedgerCalculationUtils.balanceMinor(transactions: transactions), 750)
    }

    func testDeletedTransactionsAreExcludedFromActiveTransactions() {
        let active = makeTransaction(type: .income, amountMinor: 1000)
        let deleted = makeTransaction(type: .expense, amountMinor: 250, deletedAt: Date())

        XCTAssertEqual(LedgerCalculationUtils.activeTransactions([active, deleted]), [active])
    }

    func testEmptyTransactionsReturnZeroTotals() {
        XCTAssertEqual(LedgerCalculationUtils.totalIncomeMinor(transactions: []), 0)
        XCTAssertEqual(LedgerCalculationUtils.totalExpenseMinor(transactions: []), 0)
        XCTAssertEqual(LedgerCalculationUtils.balanceMinor(transactions: []), 0)
    }

    private func makeTransaction(
        type: TransactionType,
        amountMinor: Int64,
        deletedAt: Date? = nil
    ) -> LedgerTransaction {
        LedgerTransaction(
            id: UUID(),
            bookId: UUID(),
            type: type,
            amountMinor: amountMinor,
            currencyCode: "CNY",
            categoryLevel1Id: UUID(),
            categoryLevel2Id: UUID(),
            occurredAt: Date(),
            note: nil,
            createdBy: UUID(),
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: deletedAt
        )
    }
}
