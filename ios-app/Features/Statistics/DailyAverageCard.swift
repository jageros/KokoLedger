import SwiftUI

struct DailyAverageCard: View {
    let snapshot: StatisticsSnapshot

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text("日均统计")
                    .font(.headline)

                HStack(spacing: AppTheme.Spacing.medium) {
                    averageMetric(
                        title: "日均收入",
                        amountMinor: snapshot.averageDailyIncomeMinor,
                        delta: snapshot.averageDailyIncomeDelta,
                        tint: .green
                    )
                    Divider()
                    averageMetric(
                        title: "日均支出",
                        amountMinor: snapshot.averageDailyExpenseMinor,
                        delta: snapshot.averageDailyExpenseDelta,
                        tint: .red
                    )
                }
            }
        }
    }

    private func averageMetric(
        title: String,
        amountMinor: Int64,
        delta: PercentageDelta,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(MoneyFormatter.formatCompact(amountMinor: amountMinor, currencyCode: snapshot.currencyCode))
                .font(.title3.weight(.semibold))
                .foregroundStyle(tint)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            StatDeltaBadge(delta: delta)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
