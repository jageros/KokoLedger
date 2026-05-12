import Foundation

enum BookInviteStatus: String, Codable, CaseIterable, Identifiable {
    case pending
    case joined
    case expired
    case revoked

    var id: String {
        rawValue
    }
}
