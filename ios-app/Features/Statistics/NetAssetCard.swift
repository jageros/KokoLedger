import SwiftUI

struct NetAssetCard: View {
    let snapshot: StatisticsSnapshot

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text("净资产")
                    .font(.headline)

                Text(MoneyFormatter.format(amountMinor: snapshot.netAssetMinor, currencyCode: snapshot.currencyCode))
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .monospacedDigit()

                HStack(spacing: AppTheme.Spacing.medium) {
                    amountMetric(
                        title: "总收入",
                        amountMinor: snapshot.totalIncomeMinor,
                        delta: snapshot.incomeDelta,
                        tint: .green
                    )
                    Divider()
                    amountMetric(
                        title: "总支出",
                        amountMinor: snapshot.totalExpenseMinor,
                        delta: snapshot.expenseDelta,
                        tint: .red
                    )
                }
            }
        }
    }

    private func amountMetric(
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
                .font(.headline)
                .foregroundStyle(tint)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            StatDeltaBadge(delta: delta)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
