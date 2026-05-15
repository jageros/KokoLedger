import Foundation

final class RemoteBookMemberService: BookMemberServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchMembers(bookId: UUID, requestedBy userId: UUID) async throws -> [BookMember] {
        let response: DataResponse<[BookMember]> = try await apiClient.get(.members(bookId: bookId))
        return response.data
    }

    func updateMemberRole(
        bookId: UUID,
        memberId: UUID,
        role: BookMemberRole,
        requestedBy userId: UUID
    ) async throws -> BookMember {
        let response: DataResponse<BookMember> = try await apiClient.patch(
            .updateMemberRole(bookId: bookId, memberId: memberId),
            body: UpdateMemberRoleRequest(role: role.rawValue)
        )
        return response.data
    }

    func removeMember(bookId: UUID, memberId: UUID, requestedBy userId: UUID) async throws {
        let _: EmptyAPIResponse = try await apiClient.delete(.deleteMember(bookId: bookId, memberId: memberId))
    }
}

private struct UpdateMemberRoleRequest: Encodable {
    let role: String
}
