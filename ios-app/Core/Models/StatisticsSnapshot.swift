import Foundation

struct StatisticsSnapshot: Codable, Equatable {
    let scope: StatisticsTimeScope
    let totalIncomeMinor: Int64
    let incomeDelta: PercentageDelta
    let totalExpenseMinor: Int64
    let expenseDelta: PercentageDelta
    let averageDailyIncomeMinor: Int64
    let averageDailyIncomeDelta: PercentageDelta
    let averageDailyExpenseMinor: Int64
    let averageDailyExpenseDelta: PercentageDelta
    let currencyCode: String

    var netAssetMinor: Int64 {
        totalIncomeMinor - totalExpenseMinor
    }

    init(
        scope: StatisticsTimeScope,
        totalIncomeMinor: Int64,
        incomeDelta: PercentageDelta,
        totalExpenseMinor: Int64,
        expenseDelta: PercentageDelta,
        averageDailyIncomeMinor: Int64,
        averageDailyIncomeDelta: PercentageDelta,
        averageDailyExpenseMinor: Int64,
        averageDailyExpenseDelta: PercentageDelta,
        currencyCode: String
    ) {
        self.scope = scope
        self.totalIncomeMinor = totalIncomeMinor
        self.incomeDelta = incomeDelta
        self.totalExpenseMinor = totalExpenseMinor
        self.expenseDelta = expenseDelta
        self.averageDailyIncomeMinor = averageDailyIncomeMinor
        self.averageDailyIncomeDelta = averageDailyIncomeDelta
        self.averageDailyExpenseMinor = averageDailyExpenseMinor
        self.averageDailyExpenseDelta = averageDailyExpenseDelta
        self.currencyCode = currencyCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let scope = try container.decode(StatisticsTimeScope.self, forKey: .scope)
        let totalIncomeMinor = try container.decode(Int64.self, forKey: .totalIncomeMinor)
        let incomeDelta = try container.decode(PercentageDelta.self, forKey: .incomeDelta)
        let totalExpenseMinor = try container.decode(Int64.self, forKey: .totalExpenseMinor)
        let expenseDelta = try container.decode(PercentageDelta.self, forKey: .expenseDelta)
        let averageDailyIncomeMinor = try container.decode(Int64.self, forKey: .averageDailyIncomeMinor)
        let averageDailyIncomeDelta = try container.decode(PercentageDelta.self, forKey: .averageDailyIncomeDelta)
        let averageDailyExpenseMinor = try container.decode(Int64.self, forKey: .averageDailyExpenseMinor)
        let averageDailyExpenseDelta = try container.decode(PercentageDelta.self, forKey: .averageDailyExpenseDelta)
        let currencyCode = try container.decode(String.self, forKey: .currencyCode)

        self.init(
            scope: scope,
            totalIncomeMinor: totalIncomeMinor,
            incomeDelta: incomeDelta,
            totalExpenseMinor: totalExpenseMinor,
            expenseDelta: expenseDelta,
            averageDailyIncomeMinor: averageDailyIncomeMinor,
            averageDailyIncomeDelta: averageDailyIncomeDelta,
            averageDailyExpenseMinor: averageDailyExpenseMinor,
            averageDailyExpenseDelta: averageDailyExpenseDelta,
            currencyCode: currencyCode
        )

        if let decodedNetAssetMinor = try container.decodeIfPresent(Int64.self, forKey: .netAssetMinor),
           decodedNetAssetMinor != netAssetMinor {
            throw DecodingError.dataCorruptedError(
                forKey: .netAssetMinor,
                in: container,
                debugDescription: "StatisticsSnapshot netAssetMinor must equal totalIncomeMinor - totalExpenseMinor."
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scope, forKey: .scope)
        try container.encode(totalIncomeMinor, forKey: .totalIncomeMinor)
        try container.encode(incomeDelta, forKey: .incomeDelta)
        try container.encode(totalExpenseMinor, forKey: .totalExpenseMinor)
        try container.encode(expenseDelta, forKey: .expenseDelta)
        try container.encode(netAssetMinor, forKey: .netAssetMinor)
        try container.encode(averageDailyIncomeMinor, forKey: .averageDailyIncomeMinor)
        try container.encode(averageDailyIncomeDelta, forKey: .averageDailyIncomeDelta)
        try container.encode(averageDailyExpenseMinor, forKey: .averageDailyExpenseMinor)
        try container.encode(averageDailyExpenseDelta, forKey: .averageDailyExpenseDelta)
        try container.encode(currencyCode, forKey: .currencyCode)
    }

    private enum CodingKeys: String, CodingKey {
        case scope
        case totalIncomeMinor
        case incomeDelta
        case totalExpenseMinor
        case expenseDelta
        case netAssetMinor
        case averageDailyIncomeMinor
        case averageDailyIncomeDelta
        case averageDailyExpenseMinor
        case averageDailyExpenseDelta
        case currencyCode
    }
}
