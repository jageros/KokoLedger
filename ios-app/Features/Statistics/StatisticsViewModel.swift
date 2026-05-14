import Foundation
import Combine

@MainActor
final class StatisticsViewModel: ObservableObject {
    @Published private(set) var selectedScope: StatisticsTimeScope = .last7Days
    @Published private(set) var selectedChartDisplayType: ChartDisplayType = .line
    @Published private(set) var selectedCategoryTransactionType: TransactionType = .expense
    @Published private(set) var selectedCategoryLevel: CategoryLevel = .level1
    @Published private(set) var snapshot: StatisticsSnapshot?
    @Published private(set) var trendPoints: [TrendPoint] = []
    @Published private(set) var categoryRatioSlices: [CategoryRatioSlice] = []
    @Published private(set) var categoryRatioTotalMinor: Int64 = 0
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let session: AppSession
    private let statisticsRepository: StatisticsRepository
    private let now: () -> Date

    init(
        session: AppSession,
        statisticsRepository: StatisticsRepository? = nil,
        now: @escaping () -> Date = Date.init
    ) {
        self.session = session
        self.statisticsRepository = statisticsRepository ?? session.dependencies.statisticsRepository
        self.now = now
    }

    var currentBook: Book? {
        session.currentBook
    }

    var scopeTitle: String {
        selectedScope.title
    }

    var currencyCode: String {
        snapshot?.currencyCode ?? session.currentBook?.defaultCurrencyCode ?? "CNY"
    }

    func load() async {
        guard let userId = session.currentUser?.id, let book = session.currentBook else {
            clearData()
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let date = now()
            let loadedSnapshot = try await statisticsRepository.statisticsSnapshot(
                bookId: book.id,
                scope: selectedScope,
                relativeTo: date,
                requestedBy: userId
            )
            let loadedTrendPoints = try await statisticsRepository.trendPoints(
                bookId: book.id,
                scope: selectedScope,
                relativeTo: date,
                requestedBy: userId
            )
            let loadedSlices = try await statisticsRepository.categoryRatioSlices(
                bookId: book.id,
                scope: selectedScope,
                type: selectedCategoryTransactionType,
                level: selectedCategoryLevel,
                relativeTo: date,
                requestedBy: userId
            )

            snapshot = loadedSnapshot
            trendPoints = adaptedTrendPoints(loadedTrendPoints, scope: selectedScope)
            setCategoryRatioSlices(loadedSlices)
        } catch {
            clearData()
            errorMessage = error.localizedDescription
        }
    }

    func selectScope(_ scope: StatisticsTimeScope) async {
        guard selectedScope != scope else {
            return
        }
        selectedScope = scope
        await load()
    }

    func selectChartDisplayType(_ type: ChartDisplayType) {
        selectedChartDisplayType = type
    }

    func selectCategoryTransactionType(_ type: TransactionType) async {
        guard selectedCategoryTransactionType != type else {
            return
        }
        selectedCategoryTransactionType = type
        await loadCategoryRatioSlices()
    }

    func selectCategoryLevel(_ level: CategoryLevel) async {
        guard selectedCategoryLevel != level else {
            return
        }
        selectedCategoryLevel = level
        await loadCategoryRatioSlices()
    }

    func clearError() {
        errorMessage = nil
    }

    private func loadCategoryRatioSlices() async {
        guard let userId = session.currentUser?.id, let book = session.currentBook else {
            categoryRatioSlices = []
            categoryRatioTotalMinor = 0
            return
        }

        do {
            let loadedSlices = try await statisticsRepository.categoryRatioSlices(
                bookId: book.id,
                scope: selectedScope,
                type: selectedCategoryTransactionType,
                level: selectedCategoryLevel,
                relativeTo: now(),
                requestedBy: userId
            )
            setCategoryRatioSlices(loadedSlices)
        } catch {
            categoryRatioSlices = []
            categoryRatioTotalMinor = 0
            errorMessage = error.localizedDescription
        }
    }

    private func setCategoryRatioSlices(_ slices: [CategoryRatioSlice]) {
        categoryRatioSlices = slices
        categoryRatioTotalMinor = slices.reduce(Int64(0)) { $0 + $1.amountMinor }
    }

    private func clearData() {
        snapshot = nil
        trendPoints = []
        categoryRatioSlices = []
        categoryRatioTotalMinor = 0
    }

    private func adaptedTrendPoints(_ points: [TrendPoint], scope: StatisticsTimeScope) -> [TrendPoint] {
        let sortedPoints = points.sorted { $0.date < $1.date }
        switch scope {
        case .last7Days, .thisMonth:
            return sortedPoints
        case .thisYear, .all:
            return monthlyTrendPoints(sortedPoints)
        }
    }

    private func monthlyTrendPoints(_ points: [TrendPoint]) -> [TrendPoint] {
        let calendar = Calendar.autoupdatingCurrent
        let grouped = Dictionary(grouping: points) { point in
            let components = calendar.dateComponents([.year, .month], from: point.date)
            return "\(components.year ?? 0)-\(components.month ?? 0)"
        }

        return grouped.values.compactMap { monthPoints in
            guard let firstDate = monthPoints.map(\.date).min(),
                  let monthStart = calendar.dateInterval(of: .month, for: firstDate)?.start else {
                return nil
            }
            return TrendPoint(
                id: UUID(),
                date: monthStart,
                incomeMinor: monthPoints.reduce(Int64(0)) { $0 + $1.incomeMinor },
                expenseMinor: monthPoints.reduce(Int64(0)) { $0 + $1.expenseMinor }
            )
        }
        .sorted { $0.date < $1.date }
    }
}

extension StatisticsTimeScope {
    var title: String {
        switch self {
        case .last7Days:
            "最近 7 天"
        case .thisMonth:
            "本月"
        case .thisYear:
            "本年"
        case .all:
            "全部"
        }
    }
}

extension ChartDisplayType {
    var title: String {
        switch self {
        case .line:
            "折线"
        case .bar:
            "柱状"
        }
    }
}

extension TransactionType {
    var statisticsTitle: String {
        switch self {
        case .income:
            "收入"
        case .expense:
            "支出"
        }
    }
}

extension CategoryLevel {
    var statisticsTitle: String {
        switch self {
        case .level1:
            "一级分类"
        case .level2:
            "二级分类"
        }
    }
}
