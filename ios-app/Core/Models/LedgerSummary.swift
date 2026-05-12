import Foundation

struct LedgerSummary: Codable, Equatable {
    let totalIncomeMinor: Int64
    let totalExpenseMinor: Int64
    let currencyCode: String

    var balanceMinor: Int64 {
        totalIncomeMinor - totalExpenseMinor
    }

    init(
        totalIncomeMinor: Int64,
        totalExpenseMinor: Int64,
        currencyCode: String
    ) {
        self.totalIncomeMinor = totalIncomeMinor
        self.totalExpenseMinor = totalExpenseMinor
        self.currencyCode = currencyCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let totalIncomeMinor = try container.decode(Int64.self, forKey: .totalIncomeMinor)
        let totalExpenseMinor = try container.decode(Int64.self, forKey: .totalExpenseMinor)
        let currencyCode = try container.decode(String.self, forKey: .currencyCode)

        self.init(
            totalIncomeMinor: totalIncomeMinor,
            totalExpenseMinor: totalExpenseMinor,
            currencyCode: currencyCode
        )

        if let decodedBalanceMinor = try container.decodeIfPresent(Int64.self, forKey: .balanceMinor),
           decodedBalanceMinor != balanceMinor {
            throw DecodingError.dataCorruptedError(
                forKey: .balanceMinor,
                in: container,
                debugDescription: "LedgerSummary balanceMinor must equal totalIncomeMinor - totalExpenseMinor."
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(totalIncomeMinor, forKey: .totalIncomeMinor)
        try container.encode(totalExpenseMinor, forKey: .totalExpenseMinor)
        try container.encode(balanceMinor, forKey: .balanceMinor)
        try container.encode(currencyCode, forKey: .currencyCode)
    }

    private enum CodingKeys: String, CodingKey {
        case totalIncomeMinor
        case totalExpenseMinor
        case balanceMinor
        case currencyCode
    }
}
