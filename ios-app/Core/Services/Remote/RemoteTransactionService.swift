import Foundation

final class RemoteTransactionService: TransactionServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
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
        throw unavailable()
    }

    func fetchTransaction(id: UUID, bookId: UUID, requestedBy userId: UUID) async throws -> LedgerTransaction? {
        throw unavailable()
    }

    func fetchTransactions(bookId: UUID, requestedBy userId: UUID, range: DateInterval?) async throws -> [LedgerTransaction] {
        throw unavailable()
    }

    func updateTransaction(_ transaction: LedgerTransaction, requestedBy userId: UUID) async throws -> LedgerTransaction {
        throw unavailable()
    }

    func deleteTransaction(id: UUID, bookId: UUID, requestedBy userId: UUID) async throws {
        throw unavailable()
    }

    private func unavailable() -> AppError {
        _ = apiClient
        return .network
    }
}
