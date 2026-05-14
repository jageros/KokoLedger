import XCTest
@testable import KouKouLedger

final class InfrastructureReservationTests: XCTestCase {
    func testDependencyContainerDefaultsToMockMode() {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        XCTAssertEqual(container.backendMode, .mock)
        XCTAssertTrue(container.authService is MockAuthService)
        XCTAssertNil(container.apiClient)
    }

    func testDependencyContainerCanCreateRemoteModeServices() {
        let container = AppDependencyContainer(
            referenceDate: ServiceTestSupport.referenceDate,
            backendMode: .remote,
            baseURL: URL(string: "https://api.koukou.test")!
        )

        XCTAssertEqual(container.backendMode, .remote)
        XCTAssertTrue(container.authService is RemoteAuthService)
        XCTAssertTrue(container.bookService is RemoteBookService)
        XCTAssertTrue(container.bookMemberService is RemoteBookMemberService)
        XCTAssertTrue(container.bookInviteService is RemoteBookInviteService)
        XCTAssertTrue(container.categoryService is RemoteCategoryService)
        XCTAssertTrue(container.transactionService is RemoteTransactionService)
        XCTAssertTrue(container.statisticsService is RemoteStatisticsService)
        XCTAssertNotNil(container.apiClient)
    }

    func testRemoteServicesThrowNetworkUntilBackendIsConfigured() async {
        let container = AppDependencyContainer(backendMode: .remote)

        await XCTAssertThrowsErrorAsync {
            _ = try await container.authService.currentUser()
        }
    }

    func testAPIEndpointDefinitions() {
        let bookId = UUID(uuidString: "00000000-0000-0000-0000-00000000B001")!
        let memberId = UUID(uuidString: "00000000-0000-0000-0000-00000000B002")!
        let transactionId = UUID(uuidString: "00000000-0000-0000-0000-00000000B003")!

        XCTAssertEqual(APIEndpoint.authLogin.method, .post)
        XCTAssertEqual(APIEndpoint.authLogin.path, "/auth/login")
        XCTAssertEqual(APIEndpoint.updateMemberRole(bookId: bookId, memberId: memberId).path, "/books/\(bookId.uuidString)/members/\(memberId.uuidString)/role")
        XCTAssertEqual(APIEndpoint.deleteTransaction(bookId: bookId, transactionId: transactionId).method, .delete)

        let transactions = APIEndpoint.transactions(bookId: bookId, from: "2026-05-01", to: "2026-05-14")
        XCTAssertEqual(transactions.path, "/books/\(bookId.uuidString)/transactions")
        XCTAssertEqual(transactions.queryItems.map(\.name), ["from", "to"])

        let categoryStats = APIEndpoint.statisticsCategories(
            bookId: bookId,
            scope: .thisMonth,
            type: .expense,
            level: .level2
        )
        XCTAssertEqual(categoryStats.path, "/books/\(bookId.uuidString)/statistics/categories")
        XCTAssertEqual(categoryStats.queryItems.map(\.name), ["scope", "type", "level"])
    }

    func testAPIClientBuildsAuthorizationHeaderAndJSONBody() async throws {
        struct LoginRequest: Encodable {
            let account: String
            let password: String
        }

        let client = APIClient(
            baseURL: URL(string: "https://api.koukou.test")!,
            authTokenProvider: { "token-123" }
        )

        let request = try await client.makeURLRequest(
            APIEndpoint.authLogin,
            body: LoginRequest(account: "owner@koukou.local", password: "password123")
        )

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.absoluteString, "https://api.koukou.test/auth/login")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token-123")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNotNil(request.httpBody)
    }

    func testAuthTokenStoreSaveLoadAndClear() {
        let store = AuthTokenStore()

        store.saveToken("token-abc")
        XCTAssertEqual(store.loadToken(), "token-abc")

        store.clearToken()
        XCTAssertNil(store.loadToken())
    }

    func testSwiftDataLocalCacheServiceStoresBooksAndTransactions() async throws {
        let cache = SwiftDataLocalCacheService()
        let book = Book(
            id: UUID(),
            name: "缓存账本",
            note: nil,
            defaultCurrencyCode: "CNY",
            ownerId: UUID(),
            createdAt: ServiceTestSupport.referenceDate,
            updatedAt: ServiceTestSupport.referenceDate,
            archivedAt: nil
        )
        let transaction = LedgerTransaction(
            id: UUID(),
            bookId: book.id,
            type: .expense,
            amountMinor: 1234,
            currencyCode: "CNY",
            categoryLevel1Id: UUID(),
            categoryLevel2Id: UUID(),
            occurredAt: ServiceTestSupport.referenceDate,
            note: "缓存交易",
            createdBy: book.ownerId,
            createdAt: ServiceTestSupport.referenceDate,
            updatedAt: ServiceTestSupport.referenceDate,
            deletedAt: nil
        )

        try await cache.saveBooks([book])
        try await cache.saveTransactions([transaction])

        let loadedBooks = try await cache.loadBooks()
        let loadedTransactions = try await cache.loadTransactions(bookId: book.id)
        XCTAssertEqual(loadedBooks, [book])
        XCTAssertEqual(loadedTransactions, [transaction])

        try await cache.clearAll()
        let booksAfterClear = try await cache.loadBooks()
        let transactionsAfterClear = try await cache.loadTransactions(bookId: book.id)
        XCTAssertTrue(booksAfterClear.isEmpty)
        XCTAssertTrue(transactionsAfterClear.isEmpty)
    }
}
