import Foundation

final class MockAuthService: AuthServiceProtocol {
    private let store: MockDataStore

    init(store: MockDataStore) {
        self.store = store
    }

    func login(account: String, password: String) async throws -> User {
        guard let user = store.user(matching: account),
              store.passwords[user.id] == password else {
            throw AppError.auth
        }
        store.currentUserId = user.id
        return user
    }

    func register(email: String?, phone: String?, password: String, nickname: String) async throws -> User {
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard ValidationUtils.isValidNickname(trimmedNickname),
              password.count >= 6,
              !(trimmedEmail?.isEmpty ?? true) || !(trimmedPhone?.isEmpty ?? true) else {
            throw AppError.validation
        }

        if let trimmedEmail, !trimmedEmail.isEmpty, !ValidationUtils.isValidEmail(trimmedEmail) {
            throw AppError.validation
        }
        if let trimmedPhone, !trimmedPhone.isEmpty, !ValidationUtils.isValidPhone(trimmedPhone) {
            throw AppError.validation
        }

        let normalizedEmail = trimmedEmail?.isEmpty == true ? nil : trimmedEmail
        let normalizedPhone = trimmedPhone?.isEmpty == true ? nil : trimmedPhone
        let duplicate = store.users.values.contains { user in
            (normalizedEmail != nil && user.email?.lowercased() == normalizedEmail?.lowercased())
                || (normalizedPhone != nil && user.phone == normalizedPhone)
        }
        guard !duplicate else {
            throw AppError.validation
        }

        let user = User(
            id: UUID(),
            nickname: trimmedNickname,
            avatarURL: nil,
            email: normalizedEmail,
            phone: normalizedPhone,
            createdAt: store.now,
            updatedAt: store.now
        )
        store.users[user.id] = user
        store.passwords[user.id] = password
        store.currentUserId = user.id
        return user
    }

    func logout() async throws {
        store.currentUserId = nil
    }

    func currentUser() async throws -> User? {
        store.currentUser()
    }

    func user(id: UUID) async throws -> User? {
        store.user(id: id)
    }
}

final class MockBookService: BookServiceProtocol {
    private let store: MockDataStore

    init(store: MockDataStore) {
        self.store = store
    }

    func fetchBooks(for userId: UUID) async throws -> [Book] {
        store.books.values
            .filter { book in
                !book.isArchived
                    && (book.ownerId == userId || store.member(bookId: book.id, userId: userId) != nil)
            }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    func fetchBook(id: UUID, userId: UUID) async throws -> Book? {
        guard let book = store.book(id: id), !book.isArchived else {
            return nil
        }
        return PermissionGuard.canViewBook(
            userId: userId,
            book: book,
            memberRole: store.role(bookId: book.id, userId: userId)
        ) ? book : nil
    }

    func createBook(name: String, note: String?, defaultCurrencyCode: String, ownerId: UUID) async throws -> Book {
        try ValidationUtils.validateBookName(name)
        guard store.user(id: ownerId) != nil else {
            throw AppError.auth
        }

        let book = Book(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            note: normalized(note),
            defaultCurrencyCode: defaultCurrencyCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "CNY" : defaultCurrencyCode,
            ownerId: ownerId,
            createdAt: store.now,
            updatedAt: store.now,
            archivedAt: nil
        )
        let member = BookMember(id: UUID(), bookId: book.id, userId: ownerId, role: .editor, joinedAt: store.now)
        store.books[book.id] = book
        store.members[member.id] = member
        return book
    }

    func updateBook(_ book: Book, requestedBy userId: UUID) async throws -> Book {
        guard let existing = store.book(id: book.id) else {
            throw AppError.data
        }
        try PermissionGuard.assertAllowedForBookSettings(
            userId: userId,
            book: existing,
            memberRole: store.role(bookId: existing.id, userId: userId)
        )
        try ValidationUtils.validateBookName(book.name)

        let updated = Book(
            id: existing.id,
            name: book.name.trimmingCharacters(in: .whitespacesAndNewlines),
            note: normalized(book.note),
            defaultCurrencyCode: book.defaultCurrencyCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? existing.defaultCurrencyCode
                : book.defaultCurrencyCode,
            ownerId: existing.ownerId,
            createdAt: existing.createdAt,
            updatedAt: store.now,
            archivedAt: existing.archivedAt
        )
        store.books[updated.id] = updated
        return updated
    }

    func archiveBook(id: UUID, requestedBy userId: UUID) async throws {
        guard let existing = store.book(id: id) else {
            throw AppError.data
        }
        try PermissionGuard.assertCanArchiveBook(
            userId: userId,
            book: existing,
            memberRole: store.role(bookId: existing.id, userId: userId)
        )
        store.books[id] = Book(
            id: existing.id,
            name: existing.name,
            note: existing.note,
            defaultCurrencyCode: existing.defaultCurrencyCode,
            ownerId: existing.ownerId,
            createdAt: existing.createdAt,
            updatedAt: store.now,
            archivedAt: store.now
        )
    }

    private func normalized(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == true ? nil : trimmed
    }
}

final class MockBookMemberService: BookMemberServiceProtocol {
    private let store: MockDataStore

    init(store: MockDataStore) {
        self.store = store
    }

    func fetchMembers(bookId: UUID, requestedBy userId: UUID) async throws -> [BookMember] {
        guard let book = store.book(id: bookId) else {
            throw AppError.data
        }
        guard PermissionGuard.canViewBook(userId: userId, book: book, memberRole: store.role(bookId: bookId, userId: userId)) else {
            throw AppError.permission
        }
        return store.members.values
            .filter { $0.bookId == bookId }
            .sorted { lhs, rhs in
                if lhs.userId == book.ownerId { return true }
                if rhs.userId == book.ownerId { return false }
                return lhs.joinedAt < rhs.joinedAt
            }
    }

    func updateMemberRole(
        bookId: UUID,
        memberId: UUID,
        role: BookMemberRole,
        requestedBy userId: UUID
    ) async throws -> BookMember {
        guard let book = store.book(id: bookId),
              var member = store.member(bookId: bookId, memberOrUserId: memberId) else {
            throw AppError.data
        }
        try PermissionGuard.assertCanUpdateMemberRole(
            userId: userId,
            book: book,
            memberRole: store.role(bookId: bookId, userId: userId)
        )
        guard member.userId != book.ownerId else {
            throw AppError.permission
        }
        member = BookMember(id: member.id, bookId: member.bookId, userId: member.userId, role: role, joinedAt: member.joinedAt)
        store.members[member.id] = member
        return member
    }

    func removeMember(bookId: UUID, memberId: UUID, requestedBy userId: UUID) async throws {
        guard let book = store.book(id: bookId) else {
            throw AppError.data
        }
        try PermissionGuard.assertCanRemoveMember(
            userId: userId,
            book: book,
            memberRole: store.role(bookId: bookId, userId: userId)
        )
        if memberId == book.ownerId {
            throw AppError.permission
        }
        guard let member = store.member(bookId: bookId, memberOrUserId: memberId), member.userId != book.ownerId else {
            throw AppError.permission
        }
        store.members.removeValue(forKey: member.id)
    }
}

final class MockBookInviteService: BookInviteServiceProtocol {
    private let store: MockDataStore

    init(store: MockDataStore) {
        self.store = store
    }

    func createInvite(bookId: UUID, role: BookMemberRole, requestedBy userId: UUID) async throws -> BookInvite {
        guard let book = store.book(id: bookId) else {
            throw AppError.data
        }
        try PermissionGuard.assertCanInviteMember(
            userId: userId,
            book: book,
            memberRole: store.role(bookId: bookId, userId: userId)
        )

        let code = String(UUID().uuidString.prefix(8)).uppercased()
        let invite = BookInvite(
            id: UUID(),
            bookId: bookId,
            inviteCode: code,
            inviteLink: URL(string: "koukouledger://invite/\(code)"),
            invitedByUserId: userId,
            role: role,
            status: .pending,
            expiresAt: store.now.addingTimeInterval(86_400 * 7),
            createdAt: store.now,
            acceptedAt: nil
        )
        store.invites[invite.id] = invite
        return invite
    }

    func acceptInvite(inviteCode: String, userId: UUID) async throws -> BookMember {
        let normalizedCode = inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard let invite = store.invites.values.first(where: { $0.inviteCode == normalizedCode }) else {
            throw AppError.data
        }
        guard invite.status == .pending, invite.expiresAt > store.now else {
            throw AppError.validation
        }
        guard store.user(id: userId) != nil else {
            throw AppError.auth
        }

        if let existing = store.member(bookId: invite.bookId, userId: userId) {
            return existing
        }

        let member = BookMember(id: UUID(), bookId: invite.bookId, userId: userId, role: invite.role, joinedAt: store.now)
        store.members[member.id] = member
        store.invites[invite.id] = BookInvite(
            id: invite.id,
            bookId: invite.bookId,
            inviteCode: invite.inviteCode,
            inviteLink: invite.inviteLink,
            invitedByUserId: invite.invitedByUserId,
            role: invite.role,
            status: .joined,
            expiresAt: invite.expiresAt,
            createdAt: invite.createdAt,
            acceptedAt: store.now
        )
        return member
    }

    func revokeInvite(bookId: UUID, inviteId: UUID, requestedBy userId: UUID) async throws {
        guard let invite = store.invites[inviteId],
              invite.bookId == bookId,
              let book = store.book(id: bookId) else {
            throw AppError.data
        }
        try PermissionGuard.assertCanInviteMember(
            userId: userId,
            book: book,
            memberRole: store.role(bookId: book.id, userId: userId)
        )
        store.invites[inviteId] = BookInvite(
            id: invite.id,
            bookId: invite.bookId,
            inviteCode: invite.inviteCode,
            inviteLink: invite.inviteLink,
            invitedByUserId: invite.invitedByUserId,
            role: invite.role,
            status: .revoked,
            expiresAt: invite.expiresAt,
            createdAt: invite.createdAt,
            acceptedAt: invite.acceptedAt
        )
    }
}

final class MockCategoryService: CategoryServiceProtocol {
    private let store: MockDataStore

    init(store: MockDataStore) {
        self.store = store
    }

    func fetchCategories(
        bookId: UUID,
        type: TransactionType?,
        includeArchived: Bool,
        requestedBy userId: UUID
    ) async throws -> [TransactionCategory] {
        guard let book = store.book(id: bookId) else {
            throw AppError.data
        }
        guard PermissionGuard.canViewBook(userId: userId, book: book, memberRole: store.role(bookId: bookId, userId: userId)) else {
            throw AppError.permission
        }
        return store.categories.values
            .filter { category in
                category.bookId == bookId
                    && (type == nil || category.type == type)
                    && (includeArchived || !category.isArchived)
            }
            .sorted { lhs, rhs in
                if lhs.type != rhs.type { return lhs.type.rawValue < rhs.type.rawValue }
                if lhs.level != rhs.level { return lhs.level.rawValue < rhs.level.rawValue }
                return lhs.sortOrder < rhs.sortOrder
            }
    }

    func createLevel1Category(
        bookId: UUID,
        name: String,
        type: TransactionType,
        icon: String?,
        colorHex: String?,
        requestedBy userId: UUID
    ) async throws -> TransactionCategory {
        try assertCanManage(bookId: bookId, userId: userId)
        try ValidationUtils.validateCategoryName(name)
        let category = TransactionCategory(
            id: UUID(),
            bookId: bookId,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type,
            level: .level1,
            parentId: nil,
            icon: normalized(icon),
            colorHex: normalized(colorHex),
            sortOrder: store.categories.values.filter { $0.bookId == bookId && $0.level == .level1 }.count,
            isArchived: false,
            createdAt: store.now,
            updatedAt: store.now
        )
        try CategoryRules.validateCategoryHierarchy(category)
        store.categories[category.id] = category
        return category
    }

    func createLevel2Category(
        bookId: UUID,
        parentId: UUID,
        name: String,
        icon: String?,
        colorHex: String?,
        requestedBy userId: UUID
    ) async throws -> TransactionCategory {
        try assertCanManage(bookId: bookId, userId: userId)
        try ValidationUtils.validateCategoryName(name)
        guard let parent = store.categories[parentId], parent.bookId == bookId, parent.level == .level1 else {
            throw AppError.validation
        }
        let category = TransactionCategory(
            id: UUID(),
            bookId: bookId,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            type: parent.type,
            level: .level2,
            parentId: parent.id,
            icon: normalized(icon),
            colorHex: normalized(colorHex),
            sortOrder: store.categories.values.filter { $0.bookId == bookId && $0.parentId == parent.id }.count,
            isArchived: false,
            createdAt: store.now,
            updatedAt: store.now
        )
        try CategoryRules.validateChildCategory(parent: parent, child: category)
        store.categories[category.id] = category
        return category
    }

    func updateCategory(_ category: TransactionCategory, requestedBy userId: UUID) async throws -> TransactionCategory {
        guard let existing = store.categories[category.id] else {
            throw AppError.data
        }
        try assertCanManage(bookId: existing.bookId, userId: userId)
        try ValidationUtils.validateCategoryName(category.name)
        if category.level == .level2 {
            guard let parentId = category.parentId,
                  let parent = store.categories[parentId],
                  parent.bookId == category.bookId,
                  parent.type == category.type else {
                throw AppError.validation
            }
        } else if category.parentId != nil {
            throw AppError.validation
        }
        let updated = TransactionCategory(
            id: existing.id,
            bookId: existing.bookId,
            name: category.name.trimmingCharacters(in: .whitespacesAndNewlines),
            type: category.type,
            level: category.level,
            parentId: category.parentId,
            icon: normalized(category.icon),
            colorHex: normalized(category.colorHex),
            sortOrder: category.sortOrder,
            isArchived: category.isArchived,
            createdAt: existing.createdAt,
            updatedAt: store.now
        )
        try CategoryRules.validateCategoryHierarchy(updated)
        store.categories[updated.id] = updated
        return updated
    }

    func archiveCategory(categoryId: UUID, bookId: UUID, requestedBy userId: UUID) async throws {
        guard let existing = store.categories[categoryId], existing.bookId == bookId else {
            throw AppError.data
        }
        try assertCanManage(bookId: bookId, userId: userId)
        store.categories[categoryId] = TransactionCategory(
            id: existing.id,
            bookId: existing.bookId,
            name: existing.name,
            type: existing.type,
            level: existing.level,
            parentId: existing.parentId,
            icon: existing.icon,
            colorHex: existing.colorHex,
            sortOrder: existing.sortOrder,
            isArchived: true,
            createdAt: existing.createdAt,
            updatedAt: store.now
        )
    }

    private func assertCanManage(bookId: UUID, userId: UUID) throws {
        guard let book = store.book(id: bookId) else {
            throw AppError.data
        }
        try PermissionGuard.assertCanManageCategories(
            userId: userId,
            book: book,
            memberRole: store.role(bookId: bookId, userId: userId)
        )
    }

    private func normalized(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == true ? nil : trimmed
    }
}

final class MockTransactionService: TransactionServiceProtocol {
    private let store: MockDataStore

    init(store: MockDataStore) {
        self.store = store
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
        guard let book = store.book(id: bookId) else {
            throw AppError.data
        }
        try PermissionGuard.assertCanCreateTransaction(
            userId: userId,
            book: book,
            memberRole: store.role(bookId: bookId, userId: userId)
        )
        try ValidationUtils.validateTransactionAmountMinor(amountMinor)
        guard let level1 = store.categories[categoryLevel1Id],
              let level2 = store.categories[categoryLevel2Id],
              level1.bookId == bookId,
              level2.bookId == bookId,
              level1.type == type,
              level2.type == type else {
            throw AppError.validation
        }
        try CategoryRules.validateChildCategory(parent: level1, child: level2)
        let transaction = LedgerTransaction(
            id: UUID(),
            bookId: bookId,
            type: type,
            amountMinor: amountMinor,
            currencyCode: currencyCode,
            categoryLevel1Id: categoryLevel1Id,
            categoryLevel2Id: categoryLevel2Id,
            occurredAt: occurredAt,
            note: note,
            createdBy: userId,
            createdAt: store.now,
            updatedAt: store.now,
            deletedAt: nil
        )
        store.transactions[transaction.id] = transaction
        return transaction
    }

    func fetchTransaction(id: UUID, bookId: UUID, requestedBy userId: UUID) async throws -> LedgerTransaction? {
        try assertCanView(bookId: bookId, userId: userId)
        guard let transaction = store.transactions[id], transaction.bookId == bookId, !transaction.isDeleted else {
            return nil
        }
        return transaction
    }

    func fetchTransactions(bookId: UUID, requestedBy userId: UUID, range: DateInterval?) async throws -> [LedgerTransaction] {
        try assertCanView(bookId: bookId, userId: userId)
        return store.transactions.values
            .filter { transaction in
                transaction.bookId == bookId
                    && !transaction.isDeleted
                    && (range == nil || isDate(transaction.occurredAt, in: range))
            }
            .sorted { $0.occurredAt > $1.occurredAt }
    }

    func updateTransaction(_ transaction: LedgerTransaction, requestedBy userId: UUID) async throws -> LedgerTransaction {
        guard let existing = store.transactions[transaction.id],
              existing.bookId == transaction.bookId,
              !existing.isDeleted,
              let book = store.book(id: existing.bookId) else {
            throw AppError.data
        }
        try PermissionGuard.assertCanEditTransaction(
            userId: userId,
            book: book,
            memberRole: store.role(bookId: existing.bookId, userId: userId)
        )
        guard transaction.createdBy == existing.createdBy else {
            throw AppError.permission
        }
        try validateTransactionFields(transaction)

        let updated = LedgerTransaction(
            id: existing.id,
            bookId: existing.bookId,
            type: transaction.type,
            amountMinor: transaction.amountMinor,
            currencyCode: transaction.currencyCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? existing.currencyCode
                : transaction.currencyCode,
            categoryLevel1Id: transaction.categoryLevel1Id,
            categoryLevel2Id: transaction.categoryLevel2Id,
            occurredAt: transaction.occurredAt,
            note: normalized(transaction.note),
            createdBy: existing.createdBy,
            createdAt: existing.createdAt,
            updatedAt: store.now,
            deletedAt: existing.deletedAt
        )
        store.transactions[updated.id] = updated
        return updated
    }

    func deleteTransaction(id: UUID, bookId: UUID, requestedBy userId: UUID) async throws {
        guard let book = store.book(id: bookId),
              let transaction = store.transactions[id],
              transaction.bookId == bookId else {
            throw AppError.data
        }
        try PermissionGuard.assertCanDeleteTransaction(
            userId: userId,
            book: book,
            memberRole: store.role(bookId: bookId, userId: userId)
        )
        store.transactions[id] = LedgerTransaction(
            id: transaction.id,
            bookId: transaction.bookId,
            type: transaction.type,
            amountMinor: transaction.amountMinor,
            currencyCode: transaction.currencyCode,
            categoryLevel1Id: transaction.categoryLevel1Id,
            categoryLevel2Id: transaction.categoryLevel2Id,
            occurredAt: transaction.occurredAt,
            note: transaction.note,
            createdBy: transaction.createdBy,
            createdAt: transaction.createdAt,
            updatedAt: store.now,
            deletedAt: store.now
        )
    }

    private func assertCanView(bookId: UUID, userId: UUID) throws {
        guard let book = store.book(id: bookId),
              PermissionGuard.canViewBook(userId: userId, book: book, memberRole: store.role(bookId: bookId, userId: userId)) else {
            throw AppError.permission
        }
    }

    private func validateTransactionFields(_ transaction: LedgerTransaction) throws {
        try ValidationUtils.validateTransactionAmountMinor(transaction.amountMinor)
        guard let level1 = store.categories[transaction.categoryLevel1Id],
              let level2 = store.categories[transaction.categoryLevel2Id],
              level1.bookId == transaction.bookId,
              level2.bookId == transaction.bookId,
              level1.type == transaction.type,
              level2.type == transaction.type else {
            throw AppError.validation
        }
        try CategoryRules.validateChildCategory(parent: level1, child: level2)
    }

    private func isDate(_ date: Date, in range: DateInterval?) -> Bool {
        guard let range else {
            return true
        }
        return date >= range.start && date <= range.end
    }

    private func normalized(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == true ? nil : trimmed
    }
}

final class MockStatisticsService: StatisticsServiceProtocol {
    private let store: MockDataStore

    init(store: MockDataStore) {
        self.store = store
    }

    func ledgerSummary(bookId: UUID, requestedBy userId: UUID) async throws -> LedgerSummary {
        let transactions = try activeTransactions(bookId: bookId, userId: userId, range: nil)
        let currency = store.book(id: bookId)?.defaultCurrencyCode ?? "CNY"
        return LedgerSummary(
            totalIncomeMinor: LedgerCalculationUtils.totalIncomeMinor(transactions: transactions),
            totalExpenseMinor: LedgerCalculationUtils.totalExpenseMinor(transactions: transactions),
            currencyCode: currency
        )
    }

    func statisticsSnapshot(
        bookId: UUID,
        scope: StatisticsTimeScope,
        relativeTo date: Date,
        requestedBy userId: UUID
    ) async throws -> StatisticsSnapshot {
        let range = DateUtils.range(for: scope, relativeTo: date)
        let previousRange = DateUtils.previousRange(for: scope, relativeTo: date)
        let current = try activeTransactions(bookId: bookId, userId: userId, range: range)
        let previous = try activeTransactions(bookId: bookId, userId: userId, range: previousRange)
        let income = LedgerCalculationUtils.totalIncomeMinor(transactions: current)
        let expense = LedgerCalculationUtils.totalExpenseMinor(transactions: current)
        let previousIncome = LedgerCalculationUtils.totalIncomeMinor(transactions: previous)
        let previousExpense = LedgerCalculationUtils.totalExpenseMinor(transactions: previous)
        let days = range.map(DateUtils.daysCount(in:)) ?? actualTransactionSpanDays(current)
        let previousDays = previousRange.map(DateUtils.daysCount(in:)) ?? max(previous.count, 1)
        let incomeDelta: PercentageDelta = scope == .all ? .unavailable : delta(current: income, previous: previousIncome)
        let expenseDelta: PercentageDelta = scope == .all ? .unavailable : delta(current: expense, previous: previousExpense)
        let averageIncome = income / Int64(max(days, 1))
        let averageExpense = expense / Int64(max(days, 1))
        let previousAverageIncome = previousIncome / Int64(max(previousDays, 1))
        let previousAverageExpense = previousExpense / Int64(max(previousDays, 1))

        return StatisticsSnapshot(
            scope: scope,
            totalIncomeMinor: income,
            incomeDelta: incomeDelta,
            totalExpenseMinor: expense,
            expenseDelta: expenseDelta,
            averageDailyIncomeMinor: averageIncome,
            averageDailyIncomeDelta: scope == .all ? .unavailable : delta(
                current: averageIncome,
                previous: previousAverageIncome
            ),
            averageDailyExpenseMinor: averageExpense,
            averageDailyExpenseDelta: scope == .all ? .unavailable : delta(
                current: averageExpense,
                previous: previousAverageExpense
            ),
            currencyCode: store.book(id: bookId)?.defaultCurrencyCode ?? "CNY"
        )
    }

    func trendPoints(
        bookId: UUID,
        scope: StatisticsTimeScope,
        relativeTo date: Date,
        requestedBy userId: UUID
    ) async throws -> [TrendPoint] {
        let range = DateUtils.range(for: scope, relativeTo: date)
        let transactions = try activeTransactions(bookId: bookId, userId: userId, range: range)
        let grouped = Dictionary(grouping: transactions) { DateUtils.dateKey($0.occurredAt) }
        return grouped.keys.sorted().map { key in
            let items = grouped[key] ?? []
            return TrendPoint(
                id: UUID(),
                date: items.first?.occurredAt ?? date,
                incomeMinor: LedgerCalculationUtils.totalIncomeMinor(transactions: items),
                expenseMinor: LedgerCalculationUtils.totalExpenseMinor(transactions: items)
            )
        }
    }

    func categoryRatioSlices(
        bookId: UUID,
        scope: StatisticsTimeScope,
        type: TransactionType,
        level: CategoryLevel,
        relativeTo date: Date,
        requestedBy userId: UUID
    ) async throws -> [CategoryRatioSlice] {
        let range = DateUtils.range(for: scope, relativeTo: date)
        let transactions = try activeTransactions(bookId: bookId, userId: userId, range: range)
            .filter { $0.type == type }
        let categoryId: (LedgerTransaction) -> UUID = { level == .level1 ? $0.categoryLevel1Id : $0.categoryLevel2Id }
        let grouped = Dictionary(grouping: transactions, by: categoryId)
        let total = grouped.values.flatMap { $0 }.reduce(Int64(0)) { $0 + $1.amountMinor }
        guard total > 0 else {
            return []
        }
        return grouped.map { id, items in
            let amount = items.reduce(Int64(0)) { $0 + $1.amountMinor }
            return CategoryRatioSlice(
                id: UUID(),
                categoryId: id,
                categoryName: store.categories[id]?.name ?? "未分类",
                amountMinor: amount,
                percentage: Double(amount) / Double(total) * 100
            )
        }
        .sorted { $0.amountMinor > $1.amountMinor }
    }

    private func activeTransactions(bookId: UUID, userId: UUID, range: DateInterval?) throws -> [LedgerTransaction] {
        guard let book = store.book(id: bookId),
              PermissionGuard.canViewStatistics(userId: userId, book: book, memberRole: store.role(bookId: bookId, userId: userId)) else {
            throw AppError.permission
        }
        return store.transactions.values.filter { transaction in
            transaction.bookId == bookId
                && !transaction.isDeleted
                && isDate(transaction.occurredAt, in: range)
        }
    }

    private func delta(current: Int64, previous: Int64) -> PercentageDelta {
        if previous == 0 {
            return .unavailable
        }
        let value = Double(current - previous) / Double(previous) * 100
        if value > 0 {
            return .increased(value)
        }
        if value < 0 {
            return .decreased(abs(value))
        }
        return .unchanged
    }

    private func actualTransactionSpanDays(_ transactions: [LedgerTransaction]) -> Int {
        guard let earliest = transactions.map(\.occurredAt).min(),
              let latest = transactions.map(\.occurredAt).max() else {
            return 1
        }
        return DateUtils.daysCount(in: DateInterval(start: earliest, end: max(latest, earliest.addingTimeInterval(1))))
    }

    private func isDate(_ date: Date, in range: DateInterval?) -> Bool {
        guard let range else {
            return true
        }
        return date >= range.start && date <= range.end
    }
}

private extension PermissionGuard {
    static func assertAllowedForBookSettings(userId: UUID, book: Book, memberRole: BookMemberRole?) throws {
        guard canManageBookSettings(userId: userId, book: book, memberRole: memberRole) else {
            throw AppError.permission
        }
    }
}
