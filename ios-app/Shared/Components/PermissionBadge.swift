import SwiftUI

struct PermissionBadge: View {
    let book: Book?
    let userId: UUID?
    let role: BookMemberRole?

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, AppTheme.Spacing.small)
            .padding(.vertical, AppTheme.Spacing.xSmall)
            .foregroundStyle(color)
            .background(color.opacity(0.13))
            .clipShape(Capsule())
    }

    private var title: String {
        guard let book, let userId else {
            return "无权限"
        }
        if book.ownerId == userId {
            return "Owner"
        }
        switch role {
        case .editor:
            return "Editor"
        case .readonly:
            return "Readonly"
        case .none:
            return "无权限"
        }
    }

    private var color: Color {
        switch title {
        case "Owner":
            return .purple
        case "Editor":
            return .blue
        case "Readonly":
            return .secondary
        default:
            return .red
        }
    }
}
