import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var transactions: [LedgerTransaction] = []
    @Published private(set) var todayIncomeMinor: Int64 = 0
    @Published private(set) var todayExpenseMinor: Int64 = 0
    @Published private(set) var todayBalanceMinor: Int64 = 0
    @Published private(set) var todayTransactionCount = 0
    @Published private(set) var categoryNamesById: [UUID: String] = [:]
    @Published private(set) var userNamesById: [UUID: String] = [:]
    @Published private(set) var isLoading = false
    @Published var alertMessage: String?

    private let session: AppSession
    private let transactionRepository: TransactionRepository
    private let categoryRepository: CategoryRepository
    private let memberRepository: BookMemberRepository
    private let authRepository: AuthRepository
    private let now: () -> Date

    init(session: AppSession, now: @escaping () -> Date = Date.init) {
        self.session = session
        self.now = now
        transactionRepository = session.dependencies.transactionRepository
        categoryRepository = session.dependencies.categoryRepository
        memberRepository = session.dependencies.bookMemberRepository
        authRepository = session.dependencies.authRepository
    }

    var currentUser: User? {
        session.currentUser
    }

    var currentBook: Book? {
        session.currentBook
    }

    var currentMemberRole: BookMemberRole? {
        session.currentMemberRole
    }

    var currencyCode: String {
        currentBook?.defaultCurrencyCode ?? "CNY"
    }

    var canManageTransactions: Bool {
        guard let userId = currentUser?.id, let book = currentBook else {
            return false
        }
        return PermissionGuard.canCreateTransaction(userId: userId, book: book, memberRole: currentMemberRole)
    }

    func load() async {
        guard let userId = currentUser?.id, let book = currentBook else {
            reset()
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let today = now()
            let range = DateInterval(start: DateUtils.startOfToday(relativeTo: today), end: today)
            transactions = try await transactionRepository.fetchTransactions(
                bookId: book.id,
                requestedBy: userId,
                range: range
            )
            todayIncomeMinor = LedgerCalculationUtils.totalIncomeMinor(transactions: transactions)
            todayExpenseMinor = LedgerCalculationUtils.totalExpenseMinor(transactions: transactions)
            todayBalanceMinor = LedgerCalculationUtils.balanceMinor(transactions: transactions)
            todayTransactionCount = transactions.count
            try await loadNames(bookId: book.id, userId: userId)
            alertMessage = nil
        } catch {
            reset(keepingAlert: true)
            alertMessage = message(for: error)
        }
    }

    func deleteTransaction(_ transaction: LedgerTransaction) async {
        guard let userId = currentUser?.id, let book = currentBook else {
            alertMessage = "请选择账本"
            return
        }
        do {
            try await transactionRepository.deleteTransaction(
                id: transaction.id,
                bookId: book.id,
                requestedBy: userId
            )
            await load()
        } catch {
            alertMessage = message(for: error)
        }
    }

    func categoryName(for id: UUID) -> String {
        categoryNamesById[id] ?? "未知分类"
    }

    func userName(for id: UUID) -> String {
        userNamesById[id] ?? "未知成员"
    }

    private func loadNames(bookId: UUID, userId: UUID) async throws {
        let categories = try await categoryRepository.fetchCategories(
            bookId: bookId,
            type: nil,
            includeArchived: true,
            requestedBy: userId
        )
        categoryNamesById = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0.name) })

        let members = try await memberRepository.fetchMembers(bookId: bookId, requestedBy: userId)
        var names: [UUID: String] = [:]
        for member in members {
            if let user = try await authRepository.user(id: member.userId) {
                names[user.id] = user.nickname
            }
        }
        userNamesById = names
    }

    private func reset(keepingAlert: Bool = false) {
        transactions = []
        todayIncomeMinor = 0
        todayExpenseMinor = 0
        todayBalanceMinor = 0
        todayTransactionCount = 0
        categoryNamesById = [:]
        userNamesById = [:]
        if !keepingAlert {
            alertMessage = nil
        }
    }

    private func message(for error: Error) -> String {
        switch error as? AppError {
        case .permission:
            return "当前权限不能查看或管理交易"
        case .validation:
            return "请检查交易信息"
        default:
            return "首页数据加载失败"
        }
    }
}
