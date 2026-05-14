import Foundation

protocol AuthServiceProtocol {
    func login(account: String, password: String) async throws -> User
    func register(email: String?, phone: String?, password: String, nickname: String) async throws -> User
    func logout() async throws
    func currentUser() async throws -> User?
    func user(id: UUID) async throws -> User?
}

protocol BookServiceProtocol {
    func fetchBooks(for userId: UUID) async throws -> [Book]
    func fetchBook(id: UUID, userId: UUID) async throws -> Book?
    func createBook(name: String, note: String?, defaultCurrencyCode: String, ownerId: UUID) async throws -> Book
    func updateBook(_ book: Book, requestedBy userId: UUID) async throws -> Book
    func archiveBook(id: UUID, requestedBy userId: UUID) async throws
}

protocol BookMemberServiceProtocol {
    func fetchMembers(bookId: UUID, requestedBy userId: UUID) async throws -> [BookMember]
    func updateMemberRole(
        bookId: UUID,
        memberId: UUID,
        role: BookMemberRole,
        requestedBy userId: UUID
    ) async throws -> BookMember
    func removeMember(bookId: UUID, memberId: UUID, requestedBy userId: UUID) async throws
}

protocol BookInviteServiceProtocol {
    func createInvite(bookId: UUID, role: BookMemberRole, requestedBy userId: UUID) async throws -> BookInvite
    func acceptInvite(inviteCode: String, userId: UUID) async throws -> BookMember
    func revokeInvite(inviteId: UUID, requestedBy userId: UUID) async throws
}

protocol CategoryServiceProtocol {
    func fetchCategories(
        bookId: UUID,
        type: TransactionType?,
        includeArchived: Bool,
        requestedBy userId: UUID
    ) async throws -> [TransactionCategory]
    func createLevel1Category(
        bookId: UUID,
        name: String,
        type: TransactionType,
        icon: String?,
        colorHex: String?,
        requestedBy userId: UUID
    ) async throws -> TransactionCategory
    func createLevel2Category(
        bookId: UUID,
        parentId: UUID,
        name: String,
        icon: String?,
        colorHex: String?,
        requestedBy userId: UUID
    ) async throws -> TransactionCategory
    func updateCategory(_ category: TransactionCategory, requestedBy userId: UUID) async throws -> TransactionCategory
    func archiveCategory(categoryId: UUID, bookId: UUID, requestedBy userId: UUID) async throws
}

protocol TransactionServiceProtocol {
    func createTransaction(
        bookId: UUID,
        type: TransactionType,
        amountMinor: Int64,
        currencyCode: String,
        categoryLevel1Id: UUID,
        categoryLevel2Id: UUID,
        occurredAt: Date,
        note: String?,
        createdBy userId: UUID
    ) async throws -> LedgerTransaction
    func fetchTransaction(id: UUID, bookId: UUID, requestedBy userId: UUID) async throws -> LedgerTransaction?
    func fetchTransactions(bookId: UUID, requestedBy userId: UUID, range: DateInterval?) async throws -> [LedgerTransaction]
    func updateTransaction(_ transaction: LedgerTransaction, requestedBy userId: UUID) async throws -> LedgerTransaction
    func deleteTransaction(id: UUID, bookId: UUID, requestedBy userId: UUID) async throws
}

extension TransactionServiceProtocol {
    func fetchTransactions(bookId: UUID, requestedBy userId: UUID) async throws -> [LedgerTransaction] {
        try await fetchTransactions(bookId: bookId, requestedBy: userId, range: nil)
    }
}

protocol StatisticsServiceProtocol {
    func ledgerSummary(bookId: UUID, requestedBy userId: UUID) async throws -> LedgerSummary
    func statisticsSnapshot(
        bookId: UUID,
        scope: StatisticsTimeScope,
        relativeTo date: Date,
        requestedBy userId: UUID
    ) async throws -> StatisticsSnapshot
    func trendPoints(
        bookId: UUID,
        scope: StatisticsTimeScope,
        relativeTo date: Date,
        requestedBy userId: UUID
    ) async throws -> [TrendPoint]
    func categoryRatioSlices(
        bookId: UUID,
        scope: StatisticsTimeScope,
        type: TransactionType,
        level: CategoryLevel,
        relativeTo date: Date,
        requestedBy userId: UUID
    ) async throws -> [CategoryRatioSlice]
}
