import SwiftUI

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TransactionFormViewModel
    @State private var showingDeleteConfirm = false
    let onSaved: () async -> Void

    init(session: AppSession, transaction: LedgerTransaction, onSaved: @escaping () async -> Void) {
        _viewModel = StateObject(wrappedValue: TransactionFormViewModel(session: session, transaction: transaction))
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            TransactionFormView(viewModel: viewModel)
                .navigationTitle("编辑交易")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") { dismiss() }
                    }
                    ToolbarItem(placement: .destructiveAction) {
                        Button(role: .destructive) {
                            showingDeleteConfirm = true
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    AppButton("保存修改", systemImage: "checkmark", isLoading: viewModel.isLoading) {
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
                .confirmationDialog("删除后将从交易列表隐藏", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                    Button("删除交易", role: .destructive) {
                        Task {
                            if await viewModel.delete() {
                                await onSaved()
                                dismiss()
                            }
                        }
                    }
                    Button("取消", role: .cancel) {}
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
