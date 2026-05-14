import Foundation
import Combine

@MainActor
final class TransactionFormViewModel: ObservableObject {
    @Published var type: TransactionType
    @Published var amount: String
    @Published var categoryLevel1Id: UUID?
    @Published var categoryLevel2Id: UUID?
    @Published var occurredAt: Date
    @Published var note: String
    @Published private(set) var activeCategories: [TransactionCategory] = []
    @Published private(set) var isLoading = false
    @Published var alertMessage: String?

    private let session: AppSession
    private let transactionRepository: TransactionRepository
    private let categoryRepository: CategoryRepository
    private let now: () -> Date
    private let editingTransaction: LedgerTransaction?
    private var allCategories: [TransactionCategory] = []

    init(
        session: AppSession,
        transaction: LedgerTransaction? = nil,
        initialType: TransactionType = .expense,
        now: @escaping () -> Date = Date.init
    ) {
        self.session = session
        self.now = now
        editingTransaction = transaction
        transactionRepository = session.dependencies.transactionRepository
        categoryRepository = session.dependencies.categoryRepository

        if let transaction {
            type = transaction.type
            amount = MoneyFormatter.minorToDecimalString(transaction.amountMinor)
            categoryLevel1Id = transaction.categoryLevel1Id
            categoryLevel2Id = transaction.categoryLevel2Id
            occurredAt = transaction.occurredAt
            note = transaction.note ?? ""
        } else {
            type = initialType
            amount = ""
            categoryLevel1Id = nil
            categoryLevel2Id = nil
            occurredAt = now()
            note = ""
        }
    }

    var isEditing: Bool {
        editingTransaction != nil
    }

    var canManageTransactions: Bool {
        guard let userId = session.currentUser?.id, let book = session.currentBook else {
            return false
        }
        return PermissionGuard.canCreateTransaction(userId: userId, book: book, memberRole: session.currentMemberRole)
    }

    var level1Categories: [TransactionCategory] {
        activeCategories.filter { $0.type == type && $0.level == .level1 }
    }

    var level2Categories: [TransactionCategory] {
        guard let categoryLevel1Id else {
            return []
        }
        return activeCategories.filter { $0.type == type && $0.level == .level2 && $0.parentId == categoryLevel1Id }
    }

    func load() async {
        guard let userId = session.currentUser?.id, let book = session.currentBook else {
            activeCategories = []
            allCategories = []
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            allCategories = try await categoryRepository.fetchCategories(
                bookId: book.id,
                type: type,
                includeArchived: true,
                requestedBy: userId
            )
            activeCategories = try await categoryRepository.fetchCategories(
                bookId: book.id,
                type: type,
                includeArchived: false,
                requestedBy: userId
            )
            await applyRecentCategoryIfNeeded(bookId: book.id, userId: userId)
            alertMessage = nil
        } catch {
            alertMessage = message(for: error)
        }
    }

    func changeType(_ newType: TransactionType) async {
        guard newType != type else {
            return
        }
        type = newType
        categoryLevel1Id = nil
        categoryLevel2Id = nil
        await load()
    }

    func selectLevel1Category(_ categoryId: UUID?) {
        if categoryLevel1Id != categoryId {
            categoryLevel1Id = categoryId
            categoryLevel2Id = nil
        }
    }

    func save() async -> Bool {
        guard let userId = session.currentUser?.id, let book = session.currentBook else {
            alertMessage = "请选择账本"
            return false
        }
        guard canManageTransactions else {
            alertMessage = "当前权限不能记账"
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let amountMinor = try MoneyFormatter.parseAmountToMinor(amount)
            try validateSelectedCategories()

            if let editingTransaction {
                let updated = LedgerTransaction(
                    id: editingTransaction.id,
                    bookId: editingTransaction.bookId,
                    type: type,
                    amountMinor: amountMinor,
                    currencyCode: book.defaultCurrencyCode,
                    categoryLevel1Id: categoryLevel1Id!,
                    categoryLevel2Id: categoryLevel2Id!,
                    occurredAt: occurredAt,
                    note: normalizedNote,
                    createdBy: editingTransaction.createdBy,
                    createdAt: editingTransaction.createdAt,
                    updatedAt: editingTransaction.updatedAt,
                    deletedAt: editingTransaction.deletedAt
                )
                _ = try await transactionRepository.updateTransaction(updated, requestedBy: userId)
            } else {
                _ = try await transactionRepository.createTransaction(
                    bookId: book.id,
                    type: type,
                    amountMinor: amountMinor,
                    currencyCode: book.defaultCurrencyCode,
                    categoryLevel1Id: categoryLevel1Id!,
                    categoryLevel2Id: categoryLevel2Id!,
                    occurredAt: occurredAt,
                    note: normalizedNote,
                    createdBy: userId
                )
            }

            alertMessage = nil
            return true
        } catch {
            alertMessage = message(for: error)
            return false
        }
    }

    func delete() async -> Bool {
        guard let editingTransaction,
              let userId = session.currentUser?.id,
              let book = session.currentBook else {
            alertMessage = "请选择交易"
            return false
        }
        guard canManageTransactions else {
            alertMessage = "当前权限不能删除交易"
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await transactionRepository.deleteTransaction(
                id: editingTransaction.id,
                bookId: book.id,
                requestedBy: userId
            )
            alertMessage = nil
            return true
        } catch {
            alertMessage = message(for: error)
            return false
        }
    }

    private var normalizedNote: String? {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func validateSelectedCategories() throws {
        guard let categoryLevel1Id else {
            throw AppError.validation
        }
        guard let categoryLevel2Id else {
            throw AppError.validation
        }
        guard let parent = allCategories.first(where: { $0.id == categoryLevel1Id }),
              let child = allCategories.first(where: { $0.id == categoryLevel2Id }),
              parent.type == type,
              child.type == type else {
            throw AppError.validation
        }
        try CategoryRules.validateChildCategory(parent: parent, child: child)
    }

    private func applyRecentCategoryIfNeeded(bookId: UUID, userId: UUID) async {
        guard editingTransaction == nil, categoryLevel1Id == nil, categoryLevel2Id == nil else {
            return
        }
        do {
            let recent = try await transactionRepository.fetchTransactions(
                bookId: bookId,
                requestedBy: userId,
                range: nil
            )
            .first { transaction in
                transaction.type == type
                    && activeCategories.contains { $0.id == transaction.categoryLevel1Id }
                    && activeCategories.contains { $0.id == transaction.categoryLevel2Id }
            }
            categoryLevel1Id = recent?.categoryLevel1Id
            categoryLevel2Id = recent?.categoryLevel2Id
        } catch {
            // Recent category is a convenience only; a failure should not block manual entry.
        }
    }

    private func message(for error: Error) -> String {
        switch error as? AppError {
        case .permission:
            return "当前权限不能记账"
        case .validation:
            return "请检查金额和分类"
        default:
            return "交易保存失败"
        }
    }
}
