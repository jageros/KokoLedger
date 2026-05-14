import Foundation

final class RemoteBookInviteService: BookInviteServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func createInvite(bookId: UUID, role: BookMemberRole, requestedBy userId: UUID) async throws -> BookInvite {
        throw unavailable()
    }

    func acceptInvite(inviteCode: String, userId: UUID) async throws -> BookMember {
        throw unavailable()
    }

    func revokeInvite(inviteId: UUID, requestedBy userId: UUID) async throws {
        throw unavailable()
    }

    private func unavailable() -> AppError {
        _ = apiClient
        return .network
    }
}
