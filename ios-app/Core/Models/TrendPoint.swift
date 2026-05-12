import Foundation

struct TrendPoint: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let incomeMinor: Int64
    let expenseMinor: Int64
}
