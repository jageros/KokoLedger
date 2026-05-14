import SwiftUI

struct StatisticsView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ObservedObject private var session: AppSession
    @StateObject private var viewModel: StatisticsViewModel
    @State private var showingBookSwitcher = false

    init(session: AppSession) {
        self.session = session
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(session: session))
    }

    var body: some View {
        Group {
            if session.currentBook == nil {
                noBookView
            } else if viewModel.isLoading && viewModel.snapshot == nil {
                LoadingView(message: "正在加载统计")
            } else {
                contentView
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .task {
            await viewModel.load()
        }
        .onChange(of: session.currentBook?.id) { _, _ in
            Task { await viewModel.load() }
        }
        .sheet(isPresented: $showingBookSwitcher) {
            BookSwitcherView(session: session)
                .presentationDetents([.medium, .large])
        }
        .alert("统计加载失败", isPresented: errorBinding) {
            Button("好", role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                headerView

                StatisticsScopePicker(selectedScope: scopeBinding)
                    .padding(.horizontal, AppTheme.Spacing.medium)

                if let snapshot = viewModel.snapshot {
                    NetAssetCard(snapshot: snapshot)
                        .padding(.horizontal, AppTheme.Spacing.medium)
                    DailyAverageCard(snapshot: snapshot)
                        .padding(.horizontal, AppTheme.Spacing.medium)
                }

                SectionHeaderView(title: "收支趋势")
                HStack {
                    Spacer()
                    ChartDisplayTypeToggle(selectedType: chartDisplayBinding)
                }
                .padding(.horizontal, AppTheme.Spacing.medium)

                IncomeExpenseTrendChartView(
                    points: viewModel.trendPoints,
                    displayType: viewModel.selectedChartDisplayType,
                    currencyCode: viewModel.currencyCode
                )
                .padding(.horizontal, AppTheme.Spacing.medium)

                SectionHeaderView(title: "分类占比")
                CategoryRatioControls(
                    selectedType: categoryTypeBinding,
                    selectedLevel: categoryLevelBinding
                )
                .padding(.horizontal, AppTheme.Spacing.medium)

                CategoryRatioPieChartView(
                    slices: viewModel.categoryRatioSlices,
                    totalAmountMinor: viewModel.categoryRatioTotalMinor,
                    currencyCode: viewModel.currencyCode
                )
                .padding(.horizontal, AppTheme.Spacing.medium)
            }
            .padding(.vertical, AppTheme.Spacing.medium)
            .animation(reduceMotion ? nil : AppAnimation.chart, value: viewModel.selectedScope)
            .animation(reduceMotion ? nil : AppAnimation.chart, value: viewModel.selectedChartDisplayType)
            .animation(reduceMotion ? nil : AppAnimation.chart, value: viewModel.selectedCategoryTransactionType)
            .animation(reduceMotion ? nil : AppAnimation.chart, value: viewModel.selectedCategoryLevel)
        }
        .overlay(alignment: .top) {
            if viewModel.isLoading {
                ProgressView()
                    .padding(AppTheme.Spacing.small)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
                    .padding(.top, AppTheme.Spacing.small)
            }
        }
    }

    private var headerView: some View {
        AppCard {
            HStack(alignment: .center, spacing: AppTheme.Spacing.medium) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                    Text(viewModel.currentBook?.name ?? "未选择账本")
                        .font(.title3.weight(.semibold))
                    Text(viewModel.scopeTitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    showingBookSwitcher = true
                } label: {
                    Image(systemName: "arrow.left.arrow.right.circle")
                        .font(.title3)
                }
                .accessibilityLabel("切换账本")
                if let book = viewModel.currentBook {
                    NavigationLink {
                        BookDetailView(session: session, book: book)
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.title3)
                    }
                    .accessibilityLabel("账本详情")
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.medium)
    }

    private var noBookView: some View {
        EmptyStateView(
            title: "暂无当前账本",
            message: "请选择或创建账本后查看统计分析。",
            systemImage: "chart.pie",
            actionTitle: session.accessibleBooks.isEmpty ? nil : "切换账本",
            action: session.accessibleBooks.isEmpty ? nil : { showingBookSwitcher = true }
        )
    }

    private var scopeBinding: Binding<StatisticsTimeScope> {
        Binding(
            get: { viewModel.selectedScope },
            set: { scope in Task { await viewModel.selectScope(scope) } }
        )
    }

    private var chartDisplayBinding: Binding<ChartDisplayType> {
        Binding(
            get: { viewModel.selectedChartDisplayType },
            set: { viewModel.selectChartDisplayType($0) }
        )
    }

    private var categoryTypeBinding: Binding<TransactionType> {
        Binding(
            get: { viewModel.selectedCategoryTransactionType },
            set: { type in Task { await viewModel.selectCategoryTransactionType(type) } }
        )
    }

    private var categoryLevelBinding: Binding<CategoryLevel> {
        Binding(
            get: { viewModel.selectedCategoryLevel },
            set: { level in Task { await viewModel.selectCategoryLevel(level) } }
        )
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.clearError()
                }
            }
        )
    }
}
