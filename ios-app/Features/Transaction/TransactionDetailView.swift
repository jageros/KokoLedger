import SwiftUI

struct TransactionDetailView: View {
    let transaction: LedgerTransaction
    let currencyCode: String
    let categoryLevel1Name: String
    let categoryLevel2Name: String
    let creatorName: String

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text(transaction.type.title)
                        Spacer()
                        Text(MoneyFormatter.formatCompact(amountMinor: transaction.amountMinor, currencyCode: currencyCode))
                            .font(.headline)
                            .foregroundStyle(transaction.type == .income ? Color.green : Color.red)
                    }
                    labeledValue("一级分类", categoryLevel1Name)
                    labeledValue("二级分类", categoryLevel2Name)
                    labeledValue("记账者", creatorName)
                    labeledValue("发生时间", transaction.occurredAt.formatted(date: .abbreviated, time: .shortened))
                    labeledValue("备注", transaction.note ?? "无")
                }
            }
            .navigationTitle("交易详情")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func labeledValue(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

private extension TransactionType {
    var title: String {
        switch self {
        case .income:
            return "收入"
        case .expense:
            return "支出"
        }
    }
}
