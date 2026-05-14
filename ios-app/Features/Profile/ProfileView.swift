import SwiftUI

struct ProfileView: View {
    @ObservedObject private var session: AppSession
    @StateObject private var viewModel: ProfileViewModel
    @State private var showingBookSwitcher = false
    @State private var showingLogoutConfirm = false

    init(session: AppSession) {
        self.session = session
        _viewModel = StateObject(wrappedValue: ProfileViewModel(session: session))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.medium) {
                userCard
                LedgerSummaryCard(summary: viewModel.summary)
                managementSection
                AppButton("退出登录", systemImage: "rectangle.portrait.and.arrow.right", style: .destructive) {
                    showingLogoutConfirm = true
                }
                .padding(.top, AppTheme.Spacing.small)
            }
            .padding(AppTheme.Spacing.medium)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("我的")
        .task {
            await viewModel.load()
        }
        .onChange(of: session.currentBook?.id) { _ in
            Task { await viewModel.load() }
        }
        .onChange(of: session.currentUser?.id) { _ in
            Task { await viewModel.load() }
        }
        .refreshable {
            await viewModel.load()
        }
        .sheet(isPresented: $showingBookSwitcher) {
            BookSwitcherView(session: session)
                .presentationDetents([.medium, .large])
        }
        .confirmationDialog("确认退出登录？", isPresented: $showingLogoutConfirm, titleVisibility: .visible) {
            Button("退出登录", role: .destructive) {
                Task { await viewModel.logout() }
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

    private var userCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                HStack(spacing: AppTheme.Spacing.medium) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.16))
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                    }
                    .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                        Text(viewModel.user?.nickname ?? "未登录")
                            .font(.title3.weight(.semibold))
                        Text(viewModel.user?.email ?? viewModel.user?.phone ?? "暂无账号标识")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                Divider()

                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                        Text("当前账本")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(viewModel.book?.name ?? "暂无账本")
                            .font(.headline)
                    }
                    Spacer()
                    PermissionBadge(book: viewModel.book, userId: viewModel.user?.id, role: viewModel.role)
                }

                AppButton("切换账本", systemImage: "arrow.left.arrow.right", style: .secondary) {
                    showingBookSwitcher = true
                }
                .disabled(session.accessibleBooks.isEmpty)
            }
        }
    }

    private var managementSection: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            SectionHeaderView(title: "管理")
            AppCard {
                VStack(spacing: 0) {
                    navigationRow(title: "账本管理", systemImage: "books.vertical", destination: BookListView(session: session))
                    Divider()
                    navigationRow(title: "成员管理", systemImage: "person.2", destination: BookMembersView(session: session))
                    Divider()
                    navigationRow(title: "分类管理", systemImage: "tag", destination: CategoryManagementView(session: session))
                }
            }
        }
    }

    private func navigationRow<Destination: View>(
        title: String,
        systemImage: String,
        destination: Destination
    ) -> some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: AppTheme.Spacing.medium) {
                Image(systemName: systemImage)
                    .frame(width: 24)
                    .foregroundStyle(Color.accentColor)
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, AppTheme.Spacing.medium)
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )
    }
}
