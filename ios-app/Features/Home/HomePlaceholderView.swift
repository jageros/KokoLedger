import SwiftUI

struct HomePlaceholderView: View {
    let book: Book?

    var body: some View {
        PlaceholderPageView(
            title: "首页 / 记账",
            systemImage: "square.and.pencil",
            message: book.map { "当前账本：\($0.name)。记账表单将在下一阶段实现。" } ?? "请先创建或选择账本。"
        )
    }
}

#Preview {
    HomePlaceholderView(book: nil)
}
