import SwiftUI
import UIKit

struct InviteMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MembersViewModel
    @State private var selectedRole: BookMemberRole = .editor

    var body: some View {
        NavigationStack {
            Form {
                Section("邀请权限") {
                    Picker("权限", selection: $selectedRole) {
                        Text("Editor").tag(BookMemberRole.editor)
                        Text("Readonly").tag(BookMemberRole.readonly)
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    AppButton(
                        "生成邀请码",
                        systemImage: "link.badge.plus",
                        isLoading: viewModel.isLoading
                    ) {
                        Task { await viewModel.createInvite(role: selectedRole) }
                    }
                }

                if let invite = viewModel.createdInvite {
                    Section("邀请码") {
                        copyRow(title: "邀请码", value: invite.inviteCode)
                        if let inviteLink = invite.inviteLink?.absoluteString {
                            copyRow(title: "邀请链接", value: inviteLink)
                        }
                    }
                }
            }
            .navigationTitle("邀请成员")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }

    private func copyRow(title: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body.monospaced())
            }
            Spacer()
            Button {
                UIPasteboard.general.string = value
            } label: {
                Image(systemName: "doc.on.doc")
            }
        }
    }
}
