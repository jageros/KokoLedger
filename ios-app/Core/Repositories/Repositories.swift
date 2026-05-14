import Foundation

final class AuthRepository {
    private let service: AuthServiceProtocol

    init(service: AuthServiceProtocol) {
        self.service = service
    }

    func login(account: String, password: String) async throws -> User {
        try await service.login(account: account, password: password)
    }

    func register(email: String?, phone: String?, password: String, nickname: String) async throws -> User {
        try await service.register(email: email, phone: phone, password: password, nickname: nickname)
    }

    func logout() async throws {
        try await service.logout()
    }

    func currentUser() async throws -> User? {
        try await service.currentUser()
    }

    func user(id: UUID) async throws -> User? {
        try await service.user(id: id)
    }
}

final class BookRepository {
    private let service: BookServiceProtocol

    init(service: BookServiceProtocol) {
        self.service = service
    }

    func fetchBooks(for userId: UUID) async throws -> [Book] {
        try await service.fetchBooks(for: userId)
    }

    func fetchBook(id: UUID, userId: UUID) async throws -> Book? {
        try await service.fetchBook(id: id, userId: userId)
    }

    func createBook(name: String, note: String?, defaultCurrencyCode: String, ownerId: UUID) async throws -> Book {
        try await service.createBook(name: name, note: note, defaultCurrencyCode: defaultCurrencyCode, ownerId: ownerId)
    }

    func updateBook(_ book: Book, requestedBy userId: UUID) async throws -> Book {
        try await service.updateBook(book, requestedBy: userId)
    }

    func archiveBook(id: UUID, requestedBy userId: UUID) async throws {
        try await service.archiveBook(id: id, requestedBy: userId)
    }
}

final class BookMemberRepository {
    private let service: BookMemberServiceProtocol

    init(service: BookMemberServiceProtocol) {
        self.service = service
    }

    func fetchMembers(bookId: UUID, requestedBy userId: UUID) async throws -> [BookMember] {
        try await service.fetchMembers(bookId: bookId, requestedBy: userId)
    }

    func updateMemberRole(
        bookId: UUID,
        memberId: UUID,
        role: BookMemberRole,
        requestedBy userId: UUID
    ) async throws -> BookMember {
        try await service.updateMemberRole(bookId: bookId, memberId: memberId, role: role, requestedBy: userId)
    }

    func removeMember(bookId: UUID, memberId: UUID, requestedBy userId: UUID) async throws {
        try await service.removeMember(bookId: bookId, memberId: memberId, requestedBy: userId)
    }
}

final class BookInviteRepository {
    private let service: BookInviteServiceProtocol

    init(service: BookInviteServiceProtocol) {
        self.service = service
    }

    func createInvite(bookId: UUID, role: BookMemberRole, requestedBy userId: UUID) async throws -> BookInvite {
        try await service.createInvite(bookId: bookId, role: role, requestedBy: userId)
    }

    func acceptInvite(inviteCode: String, userId: UUID) async throws -> BookMember {
        try await service.acceptInvite(inviteCode: inviteCode, userId: userId)
    }

    func revokeInvite(inviteId: UUID, requestedBy userId: UUID) async throws {
        try await service.revokeInvite(inviteId: inviteId, requestedBy: userId)
    }
}

final class CategoryRepository {
    private let service: CategoryServiceProtocol

    init(service: CategoryServiceProtocol) {
        self.service = service
    }

    func fetchCategories(
        bookId: UUID,
        type: TransactionType?,
        includeArchived: Bool,
        requestedBy userId: UUID
    ) async throws -> [TransactionCategory] {
        try await service.fetchCategories(
            bookId: bookId,
            type: type,
            includeArchived: includeArchived,
            requestedBy: userId
        )
    }

    func createLevel1Category(
        bookId: UUID,
        name: String,
        type: TransactionType,
        icon: String?,
        colorHex: String?,
        requestedBy userId: UUID
    ) async throws -> TransactionCategory {
        try await service.createLevel1Category(
            bookId: bookId,
            name: name,
            type: type,
            icon: icon,
            colorHex: colorHex,
            requestedBy: userId
        )
    }

    func createLevel2Category(
        bookId: UUID,
        parentId: UUID,
        name: String,
        icon: String?,
        colorHex: String?,
        requestedBy userId: UUID
    ) async throws -> TransactionCategory {
        try await service.createLevel2Category(
            bookId: bookId,
            parentId: parentId,
            name: name,
            icon: icon,
            colorHex: colorHex,
            requestedBy: userId
        )
    }

    func updateCategory(_ category: TransactionCategory, requestedBy userId: UUID) async throws -> TransactionCategory {
        try await service.updateCategory(category, requestedBy: userId)
    }

    func archiveCategory(categoryId: UUID, bookId: UUID, requestedBy userId: UUID) async throws {
        try await service.archiveCategory(categoryId: categoryId, bookId: bookId, requestedBy: userId)
    }
}

final class StatisticsRepository {
    private let service: StatisticsServiceProtocol

    init(service: StatisticsServiceProtocol) {
        self.service = service
    }

    func ledgerSummary(bookId: UUID, requestedBy userId: UUID) async throws -> LedgerSummary {
        try await service.ledgerSummary(bookId: bookId, requestedBy: userId)
    }

    func statisticsSnapshot(
        bookId: UUID,
        scope: StatisticsTimeScope,
        relativeTo date: Date,
        requestedBy userId: UUID
    ) async throws -> StatisticsSnapshot {
        try await service.statisticsSnapshot(
            bookId: bookId,
            scope: scope,
            relativeTo: date,
            requestedBy: userId
        )
    }

    func trendPoints(
        bookId: UUID,
        scope: StatisticsTimeScope,
        relativeTo date: Date,
        requestedBy userId: UUID
    ) async throws -> [TrendPoint] {
        try await service.trendPoints(
            bookId: bookId,
            scope: scope,
            relativeTo: date,
            requestedBy: userId
        )
    }

    func categoryRatioSlices(
        bookId: UUID,
        scope: StatisticsTimeScope,
        type: TransactionType,
        level: CategoryLevel,
        relativeTo date: Date,
        requestedBy userId: UUID
    ) async throws -> [CategoryRatioSlice] {
        try await service.categoryRatioSlices(
            bookId: bookId,
            scope: scope,
            type: type,
            level: level,
            relativeTo: date,
            requestedBy: userId
        )
    }
}

final class TransactionRepository {
    private let service: TransactionServiceProtocol

    init(service: TransactionServiceProtocol) {
        self.service = service
    }

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
    ) async throws -> LedgerTransaction {
        try await service.createTransaction(
            bookId: bookId,
            type: type,
            amountMinor: amountMinor,
            currencyCode: currencyCode,
            categoryLevel1Id: categoryLevel1Id,
            categoryLevel2Id: categoryLevel2Id,
            occurredAt: occurredAt,
            note: note,
            createdBy: userId
        )
    }

    func fetchTransaction(id: UUID, bookId: UUID, requestedBy userId: UUID) async throws -> LedgerTransaction? {
        try await service.fetchTransaction(id: id, bookId: bookId, requestedBy: userId)
    }

    func fetchTransactions(bookId: UUID, requestedBy userId: UUID, range: DateInterval? = nil) async throws -> [LedgerTransaction] {
        try await service.fetchTransactions(bookId: bookId, requestedBy: userId, range: range)
    }

    func updateTransaction(_ transaction: LedgerTransaction, requestedBy userId: UUID) async throws -> LedgerTransaction {
        try await service.updateTransaction(transaction, requestedBy: userId)
    }

    func deleteTransaction(id: UUID, bookId: UUID, requestedBy userId: UUID) async throws {
        try await service.deleteTransaction(id: id, bookId: bookId, requestedBy: userId)
    }
}
