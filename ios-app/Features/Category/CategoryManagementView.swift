import SwiftUI

struct CategoryManagementView: View {
    @StateObject private var viewModel: CategoryViewModel
    @State private var editContext: CategoryEditContext?

    init(session: AppSession) {
        _viewModel = StateObject(wrappedValue: CategoryViewModel(session: session))
    }

    var body: some View {
        VStack(spacing: 0) {
            controls
            if viewModel.isLoading && viewModel.categories.isEmpty {
                LoadingView(message: "加载分类")
            } else if viewModel.categories.isEmpty {
                EmptyStateView(
                    title: "暂无分类",
                    message: viewModel.canManageCategories ? "添加分类后即可用于下一阶段记账。" : "当前账本暂无可查看分类。",
                    systemImage: "tag",
                    actionTitle: viewModel.canManageCategories ? "新增一级分类" : nil
                ) {
                    editContext = .createLevel1(type: viewModel.selectedType)
                }
            } else {
                CategoryTreeView(
                    viewModel: viewModel,
                    onAddChild: { parent in editContext = .createLevel2(parent: parent) },
                    onEdit: { category in editContext = .edit(category) },
                    onArchive: { category in Task { await viewModel.archiveCategory(category) } }
                )
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("分类管理")
        .toolbar {
            if viewModel.canManageCategories {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editContext = .createLevel1(type: viewModel.selectedType)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .task {
            await viewModel.loadCategories()
        }
        .onChange(of: viewModel.selectedType) {
            Task { await viewModel.loadCategories() }
        }
        .onChange(of: viewModel.includeArchived) {
            Task { await viewModel.loadCategories() }
        }
        .sheet(item: $editContext) { context in
            CategoryEditView(viewModel: viewModel, context: context)
                .presentationDetents([.medium, .large])
        }
        .alert("提示", isPresented: alertBinding) {
            Button("好", role: .cancel) {
                viewModel.alertMessage = nil
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
    }

    private var controls: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            Picker("类型", selection: $viewModel.selectedType) {
                Text("支出").tag(TransactionType.expense)
                Text("收入").tag(TransactionType.income)
            }
            .pickerStyle(.segmented)

            Toggle("显示已归档分类", isOn: $viewModel.includeArchived)
        }
        .padding(AppTheme.Spacing.medium)
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )
    }
}

enum CategoryEditContext: Identifiable {
    case createLevel1(type: TransactionType)
    case createLevel2(parent: TransactionCategory)
    case edit(TransactionCategory)

    var id: String {
        switch self {
        case let .createLevel1(type):
            return "level1-\(type.rawValue)"
        case let .createLevel2(parent):
            return "level2-\(parent.id)"
        case let .edit(category):
            return "edit-\(category.id)"
        }
    }
}
