import SwiftUI

struct HomeSummaryCard: View {
    let incomeMinor: Int64
    let expenseMinor: Int64
    let balanceMinor: Int64
    let transactionCount: Int
    let currencyCode: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                HStack {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                        Text("今日结余")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(MoneyFormatter.formatCompact(amountMinor: balanceMinor, currencyCode: currencyCode))
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(balanceMinor >= 0 ? Color.green : Color.red)
                    }
                    Spacer()
                    Text("\(transactionCount) 笔")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Divider()

                HStack(spacing: AppTheme.Spacing.medium) {
                    summaryItem(title: "收入", amountMinor: incomeMinor, color: .green)
                    summaryItem(title: "支出", amountMinor: expenseMinor, color: .red)
                }
            }
        }
    }

    private func summaryItem(title: String, amountMinor: Int64, color: Color) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(MoneyFormatter.formatCompact(amountMinor: amountMinor, currencyCode: currencyCode))
                .font(.headline)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
