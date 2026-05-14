import SwiftUI

struct CategoryTreeView: View {
    @ObservedObject var viewModel: CategoryViewModel
    let onAddChild: (TransactionCategory) -> Void
    let onEdit: (TransactionCategory) -> Void
    let onArchive: (TransactionCategory) -> Void
    @State private var expandedIds: Set<UUID> = []

    var body: some View {
        List {
            ForEach(viewModel.primaryCategories) { parent in
                DisclosureGroup(isExpanded: binding(for: parent.id)) {
                    let children = viewModel.children(of: parent)
                    if children.isEmpty {
                        Text("暂无二级分类")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(children) { child in
                            categoryRow(child, isChild: true)
                        }
                    }
                    if viewModel.canManageCategories {
                        Button {
                            onAddChild(parent)
                        } label: {
                            Label("新增二级分类", systemImage: "plus.circle")
                        }
                    }
                } label: {
                    categoryRow(parent, isChild: false)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func categoryRow(_ category: TransactionCategory, isChild: Bool) -> some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            Circle()
                .fill(color(hex: category.colorHex).opacity(0.18))
                .overlay(
                    Image(systemName: category.icon ?? "tag")
                        .font(.caption)
                        .foregroundStyle(color(hex: category.colorHex))
                )
                .frame(width: isChild ? 28 : 34, height: isChild ? 28 : 34)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                Text(category.name)
                    .font(isChild ? .subheadline : .headline)
                if category.isArchived {
                    Text("已归档")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if viewModel.canManageCategories {
                Menu {
                    Button("编辑") {
                        onEdit(category)
                    }
                    if !category.isArchived {
                        Button("归档", role: .destructive) {
                            onArchive(category)
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.xSmall)
    }

    private func binding(for id: UUID) -> Binding<Bool> {
        Binding(
            get: { expandedIds.contains(id) },
            set: { isExpanded in
                if isExpanded {
                    expandedIds.insert(id)
                } else {
                    expandedIds.remove(id)
                }
            }
        )
    }

    private func color(hex: String?) -> Color {
        guard let hex else {
            return .accentColor
        }
        return Color(hex: hex) ?? .accentColor
    }
}

private extension Color {
    init?(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard cleaned.count == 6, let value = UInt64(cleaned, radix: 16) else {
            return nil
        }
        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
