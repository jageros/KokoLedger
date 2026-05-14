import SwiftUI

struct StatisticsScopePicker: View {
    @Binding var selectedScope: StatisticsTimeScope

    var body: some View {
        Picker("时间范围", selection: $selectedScope) {
            ForEach(StatisticsTimeScope.allCases) { scope in
                Text(scope.title).tag(scope)
            }
        }
        .pickerStyle(.segmented)
    }
}
