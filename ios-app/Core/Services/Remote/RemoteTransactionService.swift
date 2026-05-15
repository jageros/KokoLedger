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
        let response: DataResponse<LedgerTransaction> = try await apiClient.post(
            .createTransaction(bookId: bookId),
            body: TransactionRequest(
                type: type.rawValue,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                categoryLevel1Id: categoryLevel1Id.uuidString,
                categoryLevel2Id: categoryLevel2Id.uuidString,
                occurredAt: RemoteDateCoding.string(from: occurredAt),
                note: note
            )
        )
        return response.data
    }

    func fetchTransaction(id: UUID, bookId: UUID, requestedBy userId: UUID) async throws -> LedgerTransaction? {
        do {
            let response: DataResponse<LedgerTransaction> = try await apiClient.get(.transaction(bookId: bookId, transactionId: id))
            return response.data
        } catch APIError.notFound {
            return nil
        }
    }

    func fetchTransactions(bookId: UUID, requestedBy userId: UUID, range: DateInterval?) async throws -> [LedgerTransaction] {
        let response: DataResponse<[LedgerTransaction]> = try await apiClient.get(
            .transactions(
                bookId: bookId,
                from: range.map { RemoteDateCoding.string(from: $0.start) },
                to: range.map { RemoteDateCoding.string(from: $0.end) }
            )
        )
        return response.data
    }

    func updateTransaction(_ transaction: LedgerTransaction, requestedBy userId: UUID) async throws -> LedgerTransaction {
        let response: DataResponse<LedgerTransaction> = try await apiClient.patch(
            .updateTransaction(bookId: transaction.bookId, transactionId: transaction.id),
            body: TransactionRequest(
                type: transaction.type.rawValue,
                amountMinor: transaction.amountMinor,
                currencyCode: transaction.currencyCode,
                categoryLevel1Id: transaction.categoryLevel1Id.uuidString,
                categoryLevel2Id: transaction.categoryLevel2Id.uuidString,
                occurredAt: RemoteDateCoding.string(from: transaction.occurredAt),
                note: transaction.note
            )
        )
        return response.data
    }

    func deleteTransaction(id: UUID, bookId: UUID, requestedBy userId: UUID) async throws {
        let _: EmptyAPIResponse = try await apiClient.delete(.deleteTransaction(bookId: bookId, transactionId: id))
    }
}

private struct TransactionRequest: Encodable {
    let type: String
    let amountMinor: Int64
    let currencyCode: String
    let categoryLevel1Id: String
    let categoryLevel2Id: String
    let occurredAt: String
    let note: String?
}
