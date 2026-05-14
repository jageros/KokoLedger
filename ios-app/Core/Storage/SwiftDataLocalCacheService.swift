import Foundation

actor SwiftDataLocalCacheService: LocalCacheServiceProtocol {
    private let stack: SwiftDataStack?
    private var booksById: [UUID: Book] = [:]
    private var transactionsById: [UUID: LedgerTransaction] = [:]

    init(stack: SwiftDataStack? = nil) {
        self.stack = stack
    }

    func saveBooks(_ books: [Book]) async throws {
        for book in books {
            booksById[book.id] = book
        }
    }

    func loadBooks() async throws -> [Book] {
        booksById.values.sorted { lhs, rhs in
            if lhs.createdAt == rhs.createdAt {
                return lhs.name < rhs.name
            }
            return lhs.createdAt < rhs.createdAt
        }
    }

    func saveTransactions(_ transactions: [LedgerTransaction]) async throws {
        for transaction in transactions {
            transactionsById[transaction.id] = transaction
        }
    }

    func loadTransactions(bookId: UUID) async throws -> [LedgerTransaction] {
        transactionsById.values
            .filter { $0.bookId == bookId }
            .sorted { lhs, rhs in
                if lhs.occurredAt == rhs.occurredAt {
                    return lhs.createdAt < rhs.createdAt
                }
                return lhs.occurredAt < rhs.occurredAt
            }
    }

    func clearAll() async throws {
        booksById.removeAll()
        transactionsById.removeAll()
    }
}
