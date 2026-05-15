import Foundation

final class RemoteStatisticsService: StatisticsServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func ledgerSummary(bookId: UUID, requestedBy userId: UUID) async throws -> LedgerSummary {
        let response: DataResponse<LedgerSummary> = try await apiClient.get(.ledgerSummary(bookId: bookId))
        return response.data
    }

    func statisticsSnapshot(
        bookId: UUID,
        scope: StatisticsTimeScope,
        relativeTo date: Date,
        requestedBy userId: UUID
    ) async throws -> StatisticsSnapshot {
        let response: DataResponse<StatisticsSnapshotDTO> = try await apiClient.get(
            .statisticsSnapshot(bookId: bookId, scope: scope, relativeTo: RemoteDateCoding.string(from: date))
        )
        return response.data.model
    }

    func trendPoints(
        bookId: UUID,
        scope: StatisticsTimeScope,
        relativeTo date: Date,
        requestedBy userId: UUID
    ) async throws -> [TrendPoint] {
        let response: DataResponse<[TrendPointDTO]> = try await apiClient.get(
            .statisticsTrend(bookId: bookId, scope: scope, relativeTo: RemoteDateCoding.string(from: date))
        )
        return try response.data.map { try $0.model() }
    }

    func categoryRatioSlices(
        bookId: UUID,
        scope: StatisticsTimeScope,
        type: TransactionType,
        level: CategoryLevel,
        relativeTo date: Date,
        requestedBy userId: UUID
    ) async throws -> [CategoryRatioSlice] {
        let response: DataResponse<[CategoryRatioSlice]> = try await apiClient.get(
            .statisticsCategories(
                bookId: bookId,
                scope: scope,
                type: type,
                level: level,
                relativeTo: RemoteDateCoding.string(from: date)
            )
        )
        return response.data
    }
}

private struct StatisticsSnapshotDTO: Decodable {
    let scope: StatisticsTimeScope
    let totalIncomeMinor: Int64
    let incomeDelta: RemotePercentageDeltaDTO
    let totalExpenseMinor: Int64
    let expenseDelta: RemotePercentageDeltaDTO
    let averageDailyIncomeMinor: Int64
    let averageDailyIncomeDelta: RemotePercentageDeltaDTO
    let averageDailyExpenseMinor: Int64
    let averageDailyExpenseDelta: RemotePercentageDeltaDTO
    let currencyCode: String

    var model: StatisticsSnapshot {
        StatisticsSnapshot(
            scope: scope,
            totalIncomeMinor: totalIncomeMinor,
            incomeDelta: incomeDelta.model,
            totalExpenseMinor: totalExpenseMinor,
            expenseDelta: expenseDelta.model,
            averageDailyIncomeMinor: averageDailyIncomeMinor,
            averageDailyIncomeDelta: averageDailyIncomeDelta.model,
            averageDailyExpenseMinor: averageDailyExpenseMinor,
            averageDailyExpenseDelta: averageDailyExpenseDelta.model,
            currencyCode: currencyCode
        )
    }
}

private struct RemotePercentageDeltaDTO: Decodable {
    let kind: String
    let value: Double?

    var model: PercentageDelta {
        switch kind {
        case "unavailable":
            return .unavailable
        case "zero":
            return .zero
        case "unchanged", "flat":
            return .unchanged
        case "increased":
            return .increased(value ?? 0)
        case "decreased":
            return .decreased(value ?? 0)
        case "percent":
            let percent = (value ?? 0) * 100
            if percent > 0 {
                return .increased(percent)
            }
            if percent < 0 {
                return .decreased(abs(percent))
            }
            return .unchanged
        case "new":
            return .unavailable
        default:
            return .unavailable
        }
    }
}

private struct TrendPointDTO: Decodable {
    let id: String
    let date: String
    let incomeMinor: Int64
    let expenseMinor: Int64

    func model() throws -> TrendPoint {
        TrendPoint(
            id: UUID(uuidString: id) ?? stableUUID(from: id),
            date: try RemoteDateCoding.date(from: date),
            incomeMinor: incomeMinor,
            expenseMinor: expenseMinor
        )
    }
}

private func stableUUID(from value: String) -> UUID {
    func fnv64(_ string: String, seed: UInt64) -> UInt64 {
        var hash = seed
        for byte in string.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return hash
    }

    let high = fnv64(value, seed: 14_695_981_039_346_656_037)
    let low = fnv64(String(value.reversed()), seed: 10_995_116_282_191)
    let raw = String(format: "%016llx%016llx", high, low)
    let uuid = [
        String(raw.prefix(8)),
        String(raw.dropFirst(8).prefix(4)),
        String(raw.dropFirst(12).prefix(4)),
        String(raw.dropFirst(16).prefix(4)),
        String(raw.dropFirst(20).prefix(12))
    ].joined(separator: "-")
    return UUID(uuidString: uuid) ?? UUID()
}
