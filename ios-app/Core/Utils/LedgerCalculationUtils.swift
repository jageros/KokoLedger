import Foundation

enum LedgerCalculationUtils {
    static func totalIncomeMinor(transactions: [LedgerTransaction]) -> Int64 {
        activeTransactions(transactions)
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amountMinor }
    }

    static func totalExpenseMinor(transactions: [LedgerTransaction]) -> Int64 {
        activeTransactions(transactions)
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amountMinor }
    }

    static func balanceMinor(transactions: [LedgerTransaction]) -> Int64 {
        totalIncomeMinor(transactions: transactions) - totalExpenseMinor(transactions: transactions)
    }

    static func activeTransactions(_ transactions: [LedgerTransaction]) -> [LedgerTransaction] {
        transactions.filter { !$0.isDeleted }
    }
}
