import SwiftUI

struct AmountInputView: View {
    @Binding var amount: String

    private var validationMessage: String? {
        guard !amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        do {
            _ = try MoneyFormatter.parseAmountToMinor(amount)
            return nil
        } catch {
            return "请输入大于 0 且最多两位小数的金额"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
            Text("金额")
                .font(.subheadline.weight(.semibold))
            HStack {
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.title2.monospacedDigit())
                if !amount.isEmpty {
                    Button {
                        amount = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .frame(minHeight: 52)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous))

            if let validationMessage {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}
