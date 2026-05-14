import SwiftUI

struct LedgerSummaryCard: View {
    let summary: LedgerSummary?

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text("账本汇总")
                    .font(.headline)
                if let summary {
                    HStack {
                        summaryItem(title: "总收入", amountMinor: summary.totalIncomeMinor, color: .green)
                        Divider()
                        summaryItem(title: "总支出", amountMinor: summary.totalExpenseMinor, color: .red)
                        Divider()
                        summaryItem(title: "结余", amountMinor: summary.balanceMinor, color: .primary)
                    }
                } else {
                    Text("暂无汇总数据")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func summaryItem(title: String, amountMinor: Int64, color: Color) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(MoneyFormatter.formatCompact(amountMinor: amountMinor, currencyCode: summary?.currencyCode ?? "CNY"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
