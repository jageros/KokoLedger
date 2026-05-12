import Foundation

struct BookMember: Identifiable, Codable, Equatable {
    let id: UUID
    let bookId: UUID
    let userId: UUID
    let role: BookMemberRole
    let joinedAt: Date
}
