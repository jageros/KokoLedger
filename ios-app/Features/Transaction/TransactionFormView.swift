import SwiftUI

struct TransactionFormView: View {
    @ObservedObject var viewModel: TransactionFormViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Picker("类型", selection: typeBinding) {
                    Text("支出").tag(TransactionType.expense)
                    Text("收入").tag(TransactionType.income)
                }
                .pickerStyle(.segmented)

                AmountInputView(amount: $viewModel.amount)
                CategoryPickerView(viewModel: viewModel)

                DatePicker("发生时间", selection: $viewModel.occurredAt, displayedComponents: [.date, .hourAndMinute])

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                    Text("备注")
                        .font(.subheadline.weight(.semibold))
                    TextField("可选", text: $viewModel.note, axis: .vertical)
                        .lineLimit(2...4)
                        .padding(AppTheme.Spacing.medium)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous))
                }
            }
            .padding(AppTheme.Spacing.medium)
        }
        .animation(reduceMotion ? nil : AppAnimation.card, value: viewModel.type)
        .task {
            await viewModel.load()
        }
    }

    private var typeBinding: Binding<TransactionType> {
        Binding(
            get: { viewModel.type },
            set: { newType in
                Task { await viewModel.changeType(newType) }
            }
        )
    }
}
