import SwiftUI

struct TransactionRowView: View {
    let transaction: LedgerTransaction
    let currencyCode: String
    let categoryLevel1Name: String
    let categoryLevel2Name: String
    let creatorName: String

    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(typeColor.opacity(0.13))
                Image(systemName: transaction.type == .income ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .foregroundStyle(typeColor)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                HStack(spacing: AppTheme.Spacing.xSmall) {
                    Text(transaction.type == .income ? "收入" : "支出")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(typeColor)
                    Text("\(categoryLevel1Name) / \(categoryLevel2Name)")
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                }
                Text(transaction.note?.isEmpty == false ? transaction.note ?? "" : "无备注")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text("\(creatorName) · \(transaction.occurredAt.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Text(MoneyFormatter.formatCompact(amountMinor: transaction.amountMinor, currencyCode: currencyCode))
                .font(.headline.monospacedDigit())
                .foregroundStyle(typeColor)
        }
        .padding(AppTheme.Spacing.medium)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous))
    }

    private var typeColor: Color {
        transaction.type == .income ? .green : .red
    }
}
