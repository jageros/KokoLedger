import Foundation

final class RemoteBookService: BookServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchBooks(for userId: UUID) async throws -> [Book] {
        let response: DataResponse<[Book]> = try await apiClient.get(.books)
        return response.data
    }

    func fetchBook(id: UUID, userId: UUID) async throws -> Book? {
        do {
            let response: DataResponse<Book> = try await apiClient.get(.book(id: id))
            return response.data
        } catch APIError.notFound {
            return nil
        }
    }

    func createBook(name: String, note: String?, defaultCurrencyCode: String, ownerId: UUID) async throws -> Book {
        let response: DataResponse<Book> = try await apiClient.post(
            .createBook,
            body: BookRequest(name: name, note: note, defaultCurrencyCode: defaultCurrencyCode)
        )
        return response.data
    }

    func updateBook(_ book: Book, requestedBy userId: UUID) async throws -> Book {
        let response: DataResponse<Book> = try await apiClient.patch(
            .updateBook(id: book.id),
            body: BookRequest(name: book.name, note: book.note, defaultCurrencyCode: book.defaultCurrencyCode)
        )
        return response.data
    }

    func archiveBook(id: UUID, requestedBy userId: UUID) async throws {
        let _: EmptyAPIResponse = try await apiClient.delete(.deleteBook(id: id))
    }
}

private struct BookRequest: Encodable {
    let name: String
    let note: String?
    let defaultCurrencyCode: String
}
