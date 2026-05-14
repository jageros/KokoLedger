import SwiftUI

struct CategoryPickerView: View {
    @ObservedObject var viewModel: TransactionFormViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text("分类")
                .font(.subheadline.weight(.semibold))

            if viewModel.level1Categories.isEmpty {
                EmptyStateView(
                    title: "还没有可用分类",
                    message: "请先到我的页的分类管理中创建当前类型的一级和二级分类。",
                    systemImage: "tag"
                )
            } else {
                Picker("一级分类", selection: level1Binding) {
                    Text("选择一级分类").tag(UUID?.none)
                    ForEach(viewModel.level1Categories) { category in
                        Label(category.name, systemImage: category.icon ?? "tag")
                            .tag(Optional(category.id))
                    }
                }
                .pickerStyle(.menu)

                Picker("二级分类", selection: $viewModel.categoryLevel2Id) {
                    Text("选择二级分类").tag(UUID?.none)
                    ForEach(viewModel.level2Categories) { category in
                        Label(category.name, systemImage: category.icon ?? "tag")
                            .tag(Optional(category.id))
                    }
                }
                .pickerStyle(.menu)
                .disabled(viewModel.categoryLevel1Id == nil)
            }
        }
    }

    private var level1Binding: Binding<UUID?> {
        Binding(
            get: { viewModel.categoryLevel1Id },
            set: { viewModel.selectLevel1Category($0) }
        )
    }
}
