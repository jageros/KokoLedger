import SwiftUI

struct BookListView: View {
    @ObservedObject private var session: AppSession
    @StateObject private var viewModel: BookViewModel
    @State private var showingCreateBook = false
    @State private var showingAcceptInvite = false

    init(session: AppSession) {
        self.session = session
        _viewModel = StateObject(wrappedValue: BookViewModel(session: session))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.books.isEmpty {
                LoadingView(message: "加载账本")
            } else if viewModel.books.isEmpty {
                EmptyStateView(
                    title: "还没有账本",
                    message: "创建第一个账本，或使用邀请码加入已有账本。",
                    systemImage: "books.vertical",
                    actionTitle: "创建账本"
                ) {
                    showingCreateBook = true
                }
            } else {
                List {
                    ForEach(viewModel.books) { book in
                        BookListRow(
                            book: book,
                            isSelected: book.id == session.currentBook?.id,
                            canEdit: viewModel.canEdit(book),
                            onSwitch: {
                                Task { await viewModel.switchBook(book) }
                            },
                            detail: {
                                BookDetailView(session: session, book: book)
                            }
                        )
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("账本管理")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showingAcceptInvite = true
                } label: {
                    Image(systemName: "person.badge.plus")
                }
                Button {
                    showingCreateBook = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            await viewModel.loadBooks()
        }
        .onChange(of: session.accessibleBooks.map(\.id)) { _, _ in
            Task { await viewModel.loadBooks() }
        }
        .refreshable {
            await viewModel.loadBooks()
        }
        .sheet(isPresented: $showingCreateBook) {
            CreateBookView(viewModel: viewModel)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingAcceptInvite) {
            AcceptInviteView(session: session)
                .presentationDetents([.medium])
        }
        .alert("提示", isPresented: alertBinding) {
            Button("好", role: .cancel) {
                viewModel.alertMessage = nil
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )
    }
}

private struct BookListRow<Detail: View>: View {
    let book: Book
    let isSelected: Bool
    let canEdit: Bool
    let onSwitch: () -> Void
    let detail: () -> Detail

    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            Button(action: onSwitch) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                Text(book.name)
                    .font(.headline)
                Text(book.note ?? "默认币种 \(book.defaultCurrencyCode)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            NavigationLink(destination: detail()) {
                EmptyView()
            }
            .frame(width: 18)
        }
        .padding(.vertical, AppTheme.Spacing.small)
    }
}
