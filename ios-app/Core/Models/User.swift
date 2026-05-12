import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: UUID
    let nickname: String
    let avatarURL: URL?
    let email: String?
    let phone: String?
    let createdAt: Date
    let updatedAt: Date
}
