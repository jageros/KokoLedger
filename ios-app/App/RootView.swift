import SwiftUI

struct RootView: View {
    @ObservedObject var session: AppSession

    var body: some View {
        Group {
            if session.isBootstrapping {
                LoadingView(message: "启动中")
            } else if !session.isAuthenticated {
                AuthFlowView(session: session)
            } else if session.accessibleBooks.isEmpty {
                NoBookOnboardingView(session: session)
            } else {
                MainTabView(session: session)
            }
        }
        .task {
            await session.bootstrap()
        }
    }
}

private struct NoBookOnboardingView: View {
    @ObservedObject private var session: AppSession
    @StateObject private var viewModel: BookViewModel
    @State private var showingCreate = false

    init(session: AppSession) {
        self.session = session
        _viewModel = StateObject(wrappedValue: BookViewModel(session: session))
    }

    var body: some View {
        NavigationStack {
            EmptyStateView(
                title: "创建你的第一个账本",
                message: "账本会承载成员、分类和下一阶段首页记账数据。",
                systemImage: "books.vertical",
                actionTitle: "创建账本"
            ) {
                showingCreate = true
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("退出") {
                        Task { await session.logout() }
                    }
                }
            }
            .sheet(isPresented: $showingCreate) {
                CreateBookView(viewModel: viewModel)
                    .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    RootView(session: AppSession())
}
