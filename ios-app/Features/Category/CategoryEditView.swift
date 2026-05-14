import SwiftUI

struct CategoryEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CategoryViewModel
    let context: CategoryEditContext

    @State private var name: String
    @State private var icon: String
    @State private var colorHex: String
    @State private var type: TransactionType
    @State private var showingArchiveConfirm = false

    init(viewModel: CategoryViewModel, context: CategoryEditContext) {
        self.viewModel = viewModel
        self.context = context

        switch context {
        case let .createLevel1(type):
            _name = State(initialValue: "")
            _icon = State(initialValue: "tag")
            _colorHex = State(initialValue: type == .expense ? "#FF9500" : "#34C759")
            _type = State(initialValue: type)
        case let .createLevel2(parent):
            _name = State(initialValue: "")
            _icon = State(initialValue: parent.icon ?? "tag")
            _colorHex = State(initialValue: parent.colorHex ?? "#0A84FF")
            _type = State(initialValue: parent.type)
        case let .edit(category):
            _name = State(initialValue: category.name)
            _icon = State(initialValue: category.icon ?? "tag")
            _colorHex = State(initialValue: category.colorHex ?? "#0A84FF")
            _type = State(initialValue: category.type)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("名称", text: $name)
                    TextField("SF Symbol", text: $icon)
                    TextField("颜色 Hex", text: $colorHex)
                    Picker("类型", selection: $type) {
                        Text("支出").tag(TransactionType.expense)
                        Text("收入").tag(TransactionType.income)
                    }
                    .disabled(!canEditType)
                }

                if case let .createLevel2(parent) = context {
                    Section("父分类") {
                        Text(parent.name)
                    }
                }

                if case let .edit(category) = context, !category.isArchived {
                    Section {
                        Button("归档分类", role: .destructive) {
                            showingArchiveConfirm = true
                        }
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task { await save() }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .confirmationDialog("确认归档分类？", isPresented: $showingArchiveConfirm, titleVisibility: .visible) {
                Button("归档", role: .destructive) {
                    if case let .edit(category) = context {
                        Task {
                            await viewModel.archiveCategory(category)
                            dismiss()
                        }
                    }
                }
                Button("取消", role: .cancel) {}
            }
        }
    }

    private var title: String {
        switch context {
        case .createLevel1:
            return "新增一级分类"
        case .createLevel2:
            return "新增二级分类"
        case .edit:
            return "编辑分类"
        }
    }

    private var canEditType: Bool {
        if case .createLevel1 = context {
            return true
        }
        return false
    }

    private func save() async {
        switch context {
        case .createLevel1:
            await viewModel.createLevel1Category(name: name, icon: icon, colorHex: colorHex, type: type)
        case let .createLevel2(parent):
            await viewModel.createLevel2Category(parent: parent, name: name, icon: icon, colorHex: colorHex)
        case let .edit(category):
            let updated = TransactionCategory(
                id: category.id,
                bookId: category.bookId,
                name: name,
                type: category.level == .level1 ? type : category.type,
                level: category.level,
                parentId: category.parentId,
                icon: icon,
                colorHex: colorHex,
                sortOrder: category.sortOrder,
                isArchived: category.isArchived,
                createdAt: category.createdAt,
                updatedAt: category.updatedAt
            )
            await viewModel.updateCategory(updated)
        }

        if viewModel.alertMessage == nil {
            dismiss()
        }
    }
}
