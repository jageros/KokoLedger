import Foundation

struct BookInvite: Identifiable, Codable, Equatable {
    let id: UUID
    let bookId: UUID
    let inviteCode: String
    let inviteLink: URL?
    let invitedByUserId: UUID
    let role: BookMemberRole
    let status: BookInviteStatus
    let expiresAt: Date
    let createdAt: Date
    let acceptedAt: Date?
}
