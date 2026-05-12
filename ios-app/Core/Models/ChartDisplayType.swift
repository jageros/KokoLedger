import Foundation

enum ChartDisplayType: String, Codable, CaseIterable, Identifiable {
    case line
    case bar

    var id: String {
        rawValue
    }
}
