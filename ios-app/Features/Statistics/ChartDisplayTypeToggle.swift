import SwiftUI

struct ChartDisplayTypeToggle: View {
    @Binding var selectedType: ChartDisplayType

    var body: some View {
        Picker("图表类型", selection: $selectedType) {
            ForEach(ChartDisplayType.allCases) { type in
                Label(type.title, systemImage: type.systemImage).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 180)
    }
}

private extension ChartDisplayType {
    var systemImage: String {
        switch self {
        case .line:
            "chart.xyaxis.line"
        case .bar:
            "chart.bar"
        }
    }
}
