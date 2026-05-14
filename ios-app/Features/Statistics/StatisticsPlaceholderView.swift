import SwiftUI

struct StatisticsPlaceholderView: View {
    let book: Book?

    var body: some View {
        PlaceholderPageView(
            title: "统计 / 分析",
            systemImage: "chart.line.uptrend.xyaxis",
            message: book.map { "当前账本：\($0.name)。统计图表将在后续阶段实现。" } ?? "请先创建或选择账本。"
        )
    }
}

#Preview {
    StatisticsPlaceholderView(book: nil)
}
