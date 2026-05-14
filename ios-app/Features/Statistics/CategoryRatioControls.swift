import SwiftUI

struct CategoryRatioControls: View {
    @Binding var selectedType: TransactionType
    @Binding var selectedLevel: CategoryLevel

    var body: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Picker("分类类型", selection: $selectedType) {
                Text(TransactionType.expense.statisticsTitle).tag(TransactionType.expense)
                Text(TransactionType.income.statisticsTitle).tag(TransactionType.income)
            }
            .pickerStyle(.segmented)

            Picker("分类层级", selection: $selectedLevel) {
                Text(CategoryLevel.level1.statisticsTitle).tag(CategoryLevel.level1)
                Text(CategoryLevel.level2.statisticsTitle).tag(CategoryLevel.level2)
            }
            .pickerStyle(.segmented)
        }
    }
}
