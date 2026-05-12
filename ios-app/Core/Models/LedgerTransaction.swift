import Foundation

struct LedgerTransaction: Identifiable, Codable, Equatable {
    let id: UUID
    let bookId: UUID
    let type: TransactionType
    let amountMinor: Int64
    let currencyCode: String
    let categoryLevel1Id: UUID
    let categoryLevel2Id: UUID
    let occurredAt: Date
    let note: String?
    let createdBy: UUID
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?

    var isDeleted: Bool {
        deletedAt != nil
    }
}
