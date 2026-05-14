import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TransactionFormViewModel
    let onSaved: () async -> Void

    init(session: AppSession, initialType: TransactionType = .expense, onSaved: @escaping () async -> Void) {
        _viewModel = StateObject(wrappedValue: TransactionFormViewModel(session: session, initialType: initialType))
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            TransactionFormView(viewModel: viewModel)
                .navigationTitle(viewModel.type == .income ? "新增收入" : "新增支出")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") { dismiss() }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    AppButton("保存", systemImage: "checkmark", isLoading: viewModel.isLoading) {
                        Task {
                            if await viewModel.save() {
                                await onSaved()
                                dismiss()
                            }
                        }
                    }
                    .padding(AppTheme.Spacing.medium)
                    .background(.regularMaterial)
                }
                .alert("提示", isPresented: alertBinding) {
                    Button("好", role: .cancel) {
                        viewModel.alertMessage = nil
                    }
                } message: {
                    Text(viewModel.alertMessage ?? "")
                }
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )
    }
}
