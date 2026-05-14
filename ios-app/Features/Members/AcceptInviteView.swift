import SwiftUI

struct AcceptInviteView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: MembersViewModel
    @State private var inviteCode = ""
    @State private var switchToJoinedBook = true

    init(session: AppSession) {
        _viewModel = StateObject(wrappedValue: MembersViewModel(session: session))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("输入邀请码", text: $inviteCode)
                        .textInputAutocapitalization(.characters)
                    Toggle("加入后切换到该账本", isOn: $switchToJoinedBook)
                }
                Section {
                    AppButton(
                        "加入账本",
                        systemImage: "person.2.badge.gearshape",
                        isLoading: viewModel.isLoading,
                        isDisabled: inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ) {
                        Task {
                            await viewModel.acceptInvite(code: inviteCode, switchToJoinedBook: switchToJoinedBook)
                            if viewModel.alertMessage == nil {
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("加入账本")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
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
