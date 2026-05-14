import Foundation

final class RemoteCategoryService: CategoryServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchCategories(
        bookId: UUID,
        type: TransactionType?,
        includeArchived: Bool,
        requestedBy userId: UUID
    ) async throws -> [TransactionCategory] {
        throw unavailable()
    }

    func createLevel1Category(
        bookId: UUID,
        name: String,
        type: TransactionType,
        icon: String?,
        colorHex: String?,
        requestedBy userId: UUID
    ) async throws -> TransactionCategory {
        throw unavailable()
    }

    func createLevel2Category(
        bookId: UUID,
        parentId: UUID,
        name: String,
        icon: String?,
        colorHex: String?,
        requestedBy userId: UUID
    ) async throws -> TransactionCategory {
        throw unavailable()
    }

    func updateCategory(_ category: TransactionCategory, requestedBy userId: UUID) async throws -> TransactionCategory {
        throw unavailable()
    }

    func archiveCategory(categoryId: UUID, bookId: UUID, requestedBy userId: UUID) async throws {
        throw unavailable()
    }

    private func unavailable() -> AppError {
        _ = apiClient
        return .network
    }
}
