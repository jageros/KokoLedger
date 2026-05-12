import Foundation

enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case income
    case expense

    var id: String {
        rawValue
    }
}
