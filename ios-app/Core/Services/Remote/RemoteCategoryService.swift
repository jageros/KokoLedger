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
        let response: DataResponse<[TransactionCategory]> = try await apiClient.get(
            .categories(bookId: bookId, type: type, includeArchived: includeArchived)
        )
        return response.data
    }

    func createLevel1Category(
        bookId: UUID,
        name: String,
        type: TransactionType,
        icon: String?,
        colorHex: String?,
        requestedBy userId: UUID
    ) async throws -> TransactionCategory {
        let response: DataResponse<TransactionCategory> = try await apiClient.post(
            .createCategory(bookId: bookId),
            body: CategoryRequest(
                name: name,
                type: type.rawValue,
                level: CategoryLevel.level1.rawValue,
                parentId: nil,
                icon: icon,
                colorHex: colorHex,
                sortOrder: nil,
                isArchived: nil
            )
        )
        return response.data
    }

    func createLevel2Category(
        bookId: UUID,
        parentId: UUID,
        name: String,
        icon: String?,
        colorHex: String?,
        requestedBy userId: UUID
    ) async throws -> TransactionCategory {
        let parentType = try await parentCategoryType(bookId: bookId, parentId: parentId, requestedBy: userId)
        let response: DataResponse<TransactionCategory> = try await apiClient.post(
            .createCategory(bookId: bookId),
            body: CategoryRequest(
                name: name,
                type: parentType.rawValue,
                level: CategoryLevel.level2.rawValue,
                parentId: parentId.uuidString,
                icon: icon,
                colorHex: colorHex,
                sortOrder: nil,
                isArchived: nil
            )
        )
        return response.data
    }

    func updateCategory(_ category: TransactionCategory, requestedBy userId: UUID) async throws -> TransactionCategory {
        let response: DataResponse<TransactionCategory> = try await apiClient.patch(
            .updateCategory(bookId: category.bookId, categoryId: category.id),
            body: CategoryRequest(
                name: category.name,
                type: category.type.rawValue,
                level: category.level.rawValue,
                parentId: category.parentId?.uuidString,
                icon: category.icon,
                colorHex: category.colorHex,
                sortOrder: category.sortOrder,
                isArchived: category.isArchived
            )
        )
        return response.data
    }

    func archiveCategory(categoryId: UUID, bookId: UUID, requestedBy userId: UUID) async throws {
        let _: EmptyAPIResponse = try await apiClient.delete(.deleteCategory(bookId: bookId, categoryId: categoryId))
    }

    private func parentCategoryType(bookId: UUID, parentId: UUID, requestedBy userId: UUID) async throws -> TransactionType {
        let categories = try await fetchCategories(bookId: bookId, type: nil, includeArchived: true, requestedBy: userId)
        guard let parent = categories.first(where: { $0.id == parentId }) else {
            throw AppError.validation
        }
        return parent.type
    }
}

private struct CategoryRequest: Encodable {
    let name: String
    let type: String?
    let level: String
    let parentId: String?
    let icon: String?
    let colorHex: String?
    let sortOrder: Int?
    let isArchived: Bool?
}
