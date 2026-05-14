import SwiftUI

struct PermissionEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MembersViewModel
    let display: BookMemberDisplay
    @State private var selectedRole: BookMemberRole
    @State private var showingConfirm = false

    init(viewModel: MembersViewModel, display: BookMemberDisplay) {
        self.viewModel = viewModel
        self.display = display
        _selectedRole = State(initialValue: display.member.role)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("成员") {
                    Text(display.user.nickname)
                    Text(display.user.email ?? display.user.phone ?? "无账号标识")
                        .foregroundStyle(.secondary)
                }
                Section("权限") {
                    Picker("权限", selection: $selectedRole) {
                        Text("Editor").tag(BookMemberRole.editor)
                        Text("Readonly").tag(BookMemberRole.readonly)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("修改权限")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        showingConfirm = true
                    }
                    .disabled(selectedRole == display.member.role || viewModel.isLoading)
                }
            }
            .confirmationDialog("确认修改成员权限？", isPresented: $showingConfirm, titleVisibility: .visible) {
                Button("确认修改") {
                    Task {
                        await viewModel.updateRole(for: display.member, role: selectedRole)
                        if viewModel.alertMessage == nil {
                            dismiss()
                        }
                    }
                }
                Button("取消", role: .cancel) {}
            }
        }
    }
}
