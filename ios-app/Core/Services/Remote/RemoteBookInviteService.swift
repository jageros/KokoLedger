import Foundation

final class RemoteBookInviteService: BookInviteServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func createInvite(bookId: UUID, role: BookMemberRole, requestedBy userId: UUID) async throws -> BookInvite {
        let response: DataResponse<BookInvite> = try await apiClient.post(
            .createInvite(bookId: bookId),
            body: CreateInviteRequest(role: role.rawValue)
        )
        return response.data
    }

    func acceptInvite(inviteCode: String, userId: UUID) async throws -> BookMember {
        let response: DataResponse<BookMember> = try await apiClient.request(.acceptInvite(inviteCode: inviteCode))
        return response.data
    }

    func revokeInvite(bookId: UUID, inviteId: UUID, requestedBy userId: UUID) async throws {
        let _: EmptyAPIResponse = try await apiClient.delete(.deleteInvite(bookId: bookId, inviteId: inviteId))
    }
}

private struct CreateInviteRequest: Encodable {
    let role: String
}
