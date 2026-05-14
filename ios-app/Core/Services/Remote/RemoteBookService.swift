import Foundation

final class RemoteBookService: BookServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchBooks(for userId: UUID) async throws -> [Book] {
        throw unavailable()
    }

    func fetchBook(id: UUID, userId: UUID) async throws -> Book? {
        throw unavailable()
    }

    func createBook(name: String, note: String?, defaultCurrencyCode: String, ownerId: UUID) async throws -> Book {
        throw unavailable()
    }

    func updateBook(_ book: Book, requestedBy userId: UUID) async throws -> Book {
        throw unavailable()
    }

    func archiveBook(id: UUID, requestedBy userId: UUID) async throws {
        throw unavailable()
    }

    private func unavailable() -> AppError {
        _ = apiClient
        return .network
    }
}
