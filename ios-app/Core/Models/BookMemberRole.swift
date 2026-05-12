import Foundation

enum BookMemberRole: String, Codable, CaseIterable, Identifiable {
    case readonly
    case editor

    var id: String {
        rawValue
    }
}
