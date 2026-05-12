import Foundation

enum StatisticsTimeScope: String, Codable, CaseIterable, Identifiable {
    case last7Days
    case thisMonth
    case thisYear
    case all

    var id: String {
        rawValue
    }
}
