import Foundation

final class RemoteBookMemberService: BookMemberServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchMembers(bookId: UUID, requestedBy userId: UUID) async throws -> [BookMember] {
        throw unavailable()
    }

    func updateMemberRole(
        bookId: UUID,
        memberId: UUID,
        role: BookMemberRole,
        requestedBy userId: UUID
    ) async throws -> BookMember {
        throw unavailable()
    }

    func removeMember(bookId: UUID, memberId: UUID, requestedBy userId: UUID) async throws {
        throw unavailable()
    }

    private func unavailable() -> AppError {
        _ = apiClient
        return .network
    }
}
