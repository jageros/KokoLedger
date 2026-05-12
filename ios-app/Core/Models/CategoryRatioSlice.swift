import Foundation

struct CategoryRatioSlice: Identifiable, Codable, Equatable {
    let id: UUID
    let categoryId: UUID
    let categoryName: String
    let amountMinor: Int64
    let percentage: Double
}
