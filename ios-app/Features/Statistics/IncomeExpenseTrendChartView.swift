import Charts
import SwiftUI

struct IncomeExpenseTrendChartView: View {
    let points: [TrendPoint]
    let displayType: ChartDisplayType
    let currencyCode: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                if points.isEmpty {
                    EmptyStateView(
                        title: "暂无趋势数据",
                        message: "当前时间范围内还没有收入或支出记录。",
                        systemImage: "chart.xyaxis.line"
                    )
                } else {
                    Chart {
                        ForEach(points) { point in
                            marks(for: point, kind: .income)
                            marks(for: point, kind: .expense)
                        }
                    }
                    .chartForegroundStyleScale([
                        TrendKind.income.title: Color.green,
                        TrendKind.expense.title: Color.red
                    ])
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let amount = value.as(Double.self) {
                                    Text(MoneyFormatter.formatCompact(amountMinor: Int64(amount), currencyCode: currencyCode))
                                }
                            }
                        }
                    }
                    .frame(height: 240)
                }
            }
        }
    }

    @ChartContentBuilder
    private func marks(for point: TrendPoint, kind: TrendKind) -> some ChartContent {
        switch displayType {
        case .line:
            LineMark(
                x: .value("日期", point.date),
                y: .value("金额", Double(kind.amount(in: point))),
                series: .value("类型", kind.title)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(by: .value("类型", kind.title))
            PointMark(
                x: .value("日期", point.date),
                y: .value("金额", Double(kind.amount(in: point)))
            )
            .foregroundStyle(by: .value("类型", kind.title))
        case .bar:
            BarMark(
                x: .value("日期", point.date),
                y: .value("金额", Double(kind.amount(in: point)))
            )
            .foregroundStyle(by: .value("类型", kind.title))
            .position(by: .value("类型", kind.title))
        }
    }
}

private enum TrendKind {
    case income
    case expense

    var title: String {
        switch self {
        case .income:
            "收入"
        case .expense:
            "支出"
        }
    }

    func amount(in point: TrendPoint) -> Int64 {
        switch self {
        case .income:
            point.incomeMinor
        case .expense:
            point.expenseMinor
        }
    }
}
