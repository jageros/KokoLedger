import SwiftUI

struct MemberRowView: View {
    let display: BookMemberDisplay
    let book: Book?
    let currentUserId: UUID?
    let canManage: Bool
    let onEditRole: () -> Void
    let onRemove: () -> Void
    @State private var showingRemoveConfirm = false

    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            Circle()
                .fill(Color.accentColor.opacity(0.14))
                .overlay(
                    Text(String(display.user.nickname.prefix(1)))
                        .font(.headline)
                        .foregroundStyle(Color.accentColor)
                )
                .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                HStack {
                    Text(display.user.nickname)
                        .font(.headline)
                    PermissionBadge(book: book, userId: display.user.id, role: display.member.role)
                }
                Text(display.user.email ?? display.user.phone ?? "无账号标识")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("加入于 \(display.member.joinedAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if canManage && !isOwner && display.user.id != currentUserId {
                Menu {
                    Button("修改权限", action: onEditRole)
                    Button("移除成员", role: .destructive) {
                        showingRemoveConfirm = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.small)
        .confirmationDialog("确认移除该成员？", isPresented: $showingRemoveConfirm, titleVisibility: .visible) {
            Button("移除成员", role: .destructive, action: onRemove)
            Button("取消", role: .cancel) {}
        }
    }

    private var isOwner: Bool {
        book?.ownerId == display.user.id
    }
}
