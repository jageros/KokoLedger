import Foundation

struct Book: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let note: String?
    let defaultCurrencyCode: String
    let ownerId: UUID
    let createdAt: Date
    let updatedAt: Date
    let archivedAt: Date?

    var isArchived: Bool {
        archivedAt != nil
    }
}
