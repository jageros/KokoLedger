import SwiftUI

struct HomeView: View {
    @ObservedObject private var session: AppSession
    @StateObject private var viewModel: HomeViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showingBookSwitcher = false
    @State private var showingAddTransaction = false
    @State private var quickType: TransactionType = .expense
    @State private var editingTransaction: LedgerTransaction?
    @State private var viewingTransaction: LedgerTransaction?

    init(session: AppSession) {
        self.session = session
        _viewModel = StateObject(wrappedValue: HomeViewModel(session: session))
    }

    var body: some View {
        Group {
            if viewModel.currentBook == nil {
                EmptyStateView(
                    title: "还没有当前账本",
                    message: "创建或切换账本后，就可以在首页快速记一笔。",
                    systemImage: "books.vertical",
                    actionTitle: "切换账本"
                ) {
                    showingBookSwitcher = true
                }
            } else {
                content
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("首页")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingBookSwitcher = true
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                }
            }
        }
        .task {
            await viewModel.load()
        }
        .onChange(of: session.currentBook?.id) { _ in
            Task { await viewModel.load() }
        }
        .refreshable {
            await viewModel.load()
        }
        .sheet(isPresented: $showingBookSwitcher) {
            BookSwitcherView(session: session)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView(session: session, initialType: quickType) {
                await viewModel.load()
            }
            .presentationDetents([.large])
        }
        .sheet(item: $editingTransaction) { transaction in
            EditTransactionView(session: session, transaction: transaction) {
                await viewModel.load()
            }
            .presentationDetents([.large])
        }
        .sheet(item: $viewingTransaction) { transaction in
            TransactionDetailView(
                transaction: transaction,
                currencyCode: viewModel.currencyCode,
                categoryLevel1Name: viewModel.categoryName(for: transaction.categoryLevel1Id),
                categoryLevel2Name: viewModel.categoryName(for: transaction.categoryLevel2Id),
                creatorName: viewModel.userName(for: transaction.createdBy)
            )
            .presentationDetents([.medium, .large])
        }
        .alert("提示", isPresented: alertBinding) {
            Button("好", role: .cancel) {
                viewModel.alertMessage = nil
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.medium) {
                headerCard
                HomeSummaryCard(
                    incomeMinor: viewModel.todayIncomeMinor,
                    expenseMinor: viewModel.todayExpenseMinor,
                    balanceMinor: viewModel.todayBalanceMinor,
                    transactionCount: viewModel.todayTransactionCount,
                    currencyCode: viewModel.currencyCode
                )
                quickActions
                todayTransactions
            }
            .padding(AppTheme.Spacing.medium)
        }
        .animation(reduceMotion ? nil : AppAnimation.card, value: viewModel.transactions)
    }

    private var headerCard: some View {
        AppCard {
            HStack(alignment: .center, spacing: AppTheme.Spacing.medium) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                    Text("当前账本")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.currentBook?.name ?? "未选择账本")
                        .font(.title3.weight(.semibold))
                }
                Spacer()
                PermissionBadge(
                    book: viewModel.currentBook,
                    userId: viewModel.currentUser?.id,
                    role: viewModel.currentMemberRole
                )
                if let book = viewModel.currentBook {
                    NavigationLink {
                        BookDetailView(session: session, book: book)
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                }
            }
        }
    }

    @ViewBuilder
    private var quickActions: some View {
        if viewModel.canManageTransactions {
            HStack(spacing: AppTheme.Spacing.small) {
                AppButton("记支出", systemImage: "minus.circle", style: .primary) {
                    quickType = .expense
                    showingAddTransaction = true
                }
                AppButton("记收入", systemImage: "plus.circle", style: .secondary) {
                    quickType = .income
                    showingAddTransaction = true
                }
            }
        }
    }

    private var todayTransactions: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            SectionHeaderView(title: "今日记录")
            TransactionListView(
                transactions: viewModel.transactions,
                currencyCode: viewModel.currencyCode,
                categoryName: viewModel.categoryName(for:),
                userName: viewModel.userName(for:)
            ) { transaction in
                if viewModel.canManageTransactions {
                    editingTransaction = transaction
                } else {
                    viewingTransaction = transaction
                }
            }
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )
    }
}
