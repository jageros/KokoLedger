import Charts
import SwiftUI

struct CategoryRatioPieChartView: View {
    let slices: [CategoryRatioSlice]
    let totalAmountMinor: Int64
    let currencyCode: String

    var body: some View {
        AppCard {
            if slices.isEmpty {
                EmptyStateView(
                    title: "暂无分类占比",
                    message: "当前时间范围和分类条件下还没有可统计记录。",
                    systemImage: "chart.pie"
                )
            } else {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                    ZStack {
                        Chart(slices) { slice in
                            SectorMark(
                                angle: .value("金额", Double(slice.amountMinor)),
                                innerRadius: .ratio(0.62),
                                angularInset: 1.5
                            )
                            .foregroundStyle(by: .value("分类", slice.categoryName))
                            .annotation(position: .overlay) {
                                if slice.percentage >= 8 {
                                    Text(PercentFormatter.formatPercentage(slice.percentage))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .frame(height: 230)

                        VStack(spacing: AppTheme.Spacing.xSmall) {
                            Text("总金额")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(MoneyFormatter.formatCompact(amountMinor: totalAmountMinor, currencyCode: currencyCode))
                                .font(.headline.weight(.semibold))
                                .monospacedDigit()
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(width: 112)
                    }

                    VStack(spacing: AppTheme.Spacing.small) {
                        ForEach(slices) { slice in
                            CategoryRatioRow(slice: slice, currencyCode: currencyCode)
                        }
                    }
                }
            }
        }
    }
}

private struct CategoryRatioRow: View {
    let slice: CategoryRatioSlice
    let currencyCode: String

    var body: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            Circle()
                .fill(Color.accentColor.opacity(0.18))
                .frame(width: 10, height: 10)
            Text(slice.categoryName)
                .font(.subheadline)
            Spacer()
            Text(MoneyFormatter.formatCompact(amountMinor: slice.amountMinor, currencyCode: currencyCode))
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
            Text(PercentFormatter.formatPercentage(slice.percentage))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 56, alignment: .trailing)
        }
    }
}
