import Foundation

protocol LocalCacheServiceProtocol {
    func saveBooks(_ books: [Book]) async throws
    func loadBooks() async throws -> [Book]
    func saveTransactions(_ transactions: [LedgerTransaction]) async throws
    func loadTransactions(bookId: UUID) async throws -> [LedgerTransaction]
    func clearAll() async throws
}
