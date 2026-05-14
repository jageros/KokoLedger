import SwiftUI

struct TransactionListView: View {
    let transactions: [LedgerTransaction]
    let currencyCode: String
    let groupByDate: Bool
    let categoryName: (UUID) -> String
    let userName: (UUID) -> String
    let onSelect: (LedgerTransaction) -> Void

    init(
        transactions: [LedgerTransaction],
        currencyCode: String,
        groupByDate: Bool = false,
        categoryName: @escaping (UUID) -> String,
        userName: @escaping (UUID) -> String,
        onSelect: @escaping (LedgerTransaction) -> Void
    ) {
        self.transactions = transactions
        self.currencyCode = currencyCode
        self.groupByDate = groupByDate
        self.categoryName = categoryName
        self.userName = userName
        self.onSelect = onSelect
    }

    var body: some View {
        if transactions.isEmpty {
            EmptyStateView(
                title: "今天还没有记录",
                message: "新增一笔收入或支出后，会显示在这里。",
                systemImage: "tray"
            )
        } else if groupByDate {
            groupedList
        } else {
            LazyVStack(spacing: AppTheme.Spacing.small) {
                ForEach(transactions) { transaction in
                    rowButton(for: transaction)
                }
            }
        }
    }

    private var groupedList: some View {
        LazyVStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            ForEach(groupedDates, id: \.self) { dateKey in
                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text(dateKey)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach(groupedTransactions[dateKey] ?? []) { transaction in
                        rowButton(for: transaction)
                    }
                }
            }
        }
    }

    private func rowButton(for transaction: LedgerTransaction) -> some View {
        Button {
            onSelect(transaction)
        } label: {
            TransactionRowView(
                transaction: transaction,
                currencyCode: currencyCode,
                categoryLevel1Name: categoryName(transaction.categoryLevel1Id),
                categoryLevel2Name: categoryName(transaction.categoryLevel2Id),
                creatorName: userName(transaction.createdBy)
            )
        }
        .buttonStyle(.plain)
    }

    private var groupedTransactions: [String: [LedgerTransaction]] {
        Dictionary(grouping: transactions, by: { DateUtils.dateKey($0.occurredAt) })
    }

    private var groupedDates: [String] {
        groupedTransactions.keys.sorted(by: >)
    }
}
