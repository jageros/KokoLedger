import SwiftUI

struct BookSwitcherView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var session: AppSession
    @StateObject private var viewModel: BookViewModel

    init(session: AppSession) {
        self.session = session
        _viewModel = StateObject(wrappedValue: BookViewModel(session: session))
    }

    var body: some View {
        NavigationStack {
            List(viewModel.books) { book in
                Button {
                    Task {
                        await viewModel.switchBook(book)
                        dismiss()
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                            Text(book.name)
                                .foregroundStyle(.primary)
                            Text(book.defaultCurrencyCode)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if book.id == session.currentBook?.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }
            .navigationTitle("切换账本")
            .task {
                await viewModel.loadBooks()
            }
        }
    }
}
