import Foundation
import SwiftData

final class SwiftDataStack {
    let container: ModelContainer

    init(inMemory: Bool = true) throws {
        let schema = Schema([
            CachedBookEntity.self,
            CachedTransactionEntity.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        container = try ModelContainer(for: schema, configurations: [configuration])
    }
}

@Model
final class CachedBookEntity {
    var id: UUID
    var name: String
    var note: String?
    var defaultCurrencyCode: String
    var ownerId: UUID
    var createdAt: Date
    var updatedAt: Date
    var archivedAt: Date?

    init(book: Book) {
        id = book.id
        name = book.name
        note = book.note
        defaultCurrencyCode = book.defaultCurrencyCode
        ownerId = book.ownerId
        createdAt = book.createdAt
        updatedAt = book.updatedAt
        archivedAt = book.archivedAt
    }
}

@Model
final class CachedTransactionEntity {
    var id: UUID
    var bookId: UUID
    var typeRawValue: String
    var amountMinor: Int64
    var currencyCode: String
    var categoryLevel1Id: UUID
    var categoryLevel2Id: UUID
    var occurredAt: Date
    var note: String?
    var createdBy: UUID
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?

    init(transaction: LedgerTransaction) {
        id = transaction.id
        bookId = transaction.bookId
        typeRawValue = transaction.type.rawValue
        amountMinor = transaction.amountMinor
        currencyCode = transaction.currencyCode
        categoryLevel1Id = transaction.categoryLevel1Id
        categoryLevel2Id = transaction.categoryLevel2Id
        occurredAt = transaction.occurredAt
        note = transaction.note
        createdBy = transaction.createdBy
        createdAt = transaction.createdAt
        updatedAt = transaction.updatedAt
        deletedAt = transaction.deletedAt
    }
}
