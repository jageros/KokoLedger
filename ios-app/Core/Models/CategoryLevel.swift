import Foundation

enum CategoryLevel: String, Codable, CaseIterable, Identifiable {
    case level1
    case level2

    var id: String {
        rawValue
    }
}
