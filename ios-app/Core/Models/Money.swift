import Foundation

struct Money: Codable, Equatable {
    let amountMinor: Int64
    let currencyCode: String
}
