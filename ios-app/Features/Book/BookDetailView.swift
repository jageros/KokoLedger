import SwiftUI

struct BookDetailView: View {
    @ObservedObject private var session: AppSession
    @StateObject private var viewModel: BookViewModel
    let book: Book
    @State private var showingEdit = false
    @State private var showingArchiveConfirm = false

    init(session: AppSession, book: Book) {
        self.session = session
        self.book = book
        _viewModel = StateObject(wrappedValue: BookViewModel(session: session))
    }

    var body: some View {
        let displayedBook = session.currentBook?.id == book.id ? session.currentBook ?? book : book

        List {
            Section {
                labeledValue("名称", displayedBook.name)
                labeledValue("备注", displayedBook.note ?? "无")
                labeledValue("默认币种", displayedBook.defaultCurrencyCode)
                labeledValue("Owner", displayedBook.ownerId.uuidString.prefix(8).description)
                HStack {
                    Text("当前权限")
                    Spacer()
                    PermissionBadge(book: displayedBook, userId: session.currentUser?.id, role: session.currentRole)
                }
                labeledValue("创建时间", displayedBook.createdAt.formatted(date: .abbreviated, time: .shortened))
                labeledValue("更新时间", displayedBook.updatedAt.formatted(date: .abbreviated, time: .shortened))
            }

            Section {
                NavigationLink("成员管理") {
                    BookMembersView(session: session)
                }
                NavigationLink("分类管理") {
                    CategoryManagementView(session: session)
                }
            }

            if viewModel.canEdit(displayedBook) {
                Section {
                    Button("编辑账本") {
                        showingEdit = true
                    }
                    Button("归档账本", role: .destructive) {
                        showingArchiveConfirm = true
                    }
                }
            }
        }
        .navigationTitle("账本详情")
        .task {
            await viewModel.loadBooks()
        }
        .sheet(isPresented: $showingEdit) {
            EditBookView(viewModel: viewModel, book: displayedBook)
                .presentationDetents([.medium])
        }
        .confirmationDialog("归档后账本将从列表隐藏", isPresented: $showingArchiveConfirm, titleVisibility: .visible) {
            Button("归档账本", role: .destructive) {
                Task { await viewModel.archiveBook(displayedBook) }
            }
            Button("取消", role: .cancel) {}
        }
        .alert("提示", isPresented: alertBinding) {
            Button("好", role: .cancel) {
                viewModel.alertMessage = nil
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
    }

    private func labeledValue(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )
    }
}
