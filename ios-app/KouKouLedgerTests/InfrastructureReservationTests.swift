import XCTest
@testable import KouKouLedger

final class InfrastructureReservationTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.handler = nil
        super.tearDown()
    }

    func testDependencyContainerDefaultsToMockMode() {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        XCTAssertEqual(container.backendMode, .mock)
        XCTAssertTrue(container.authService is MockAuthService)
        XCTAssertNil(container.apiClient)
    }

    func testDependencyContainerAutomaticallyUsesRemoteWhenBaseURLIsConfigured() {
        let container = AppDependencyContainer(
            referenceDate: ServiceTestSupport.referenceDate,
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

    func testDependencyContainerExplicitMockOverridesConfiguredBaseURL() {
        let container = AppDependencyContainer(
            referenceDate: ServiceTestSupport.referenceDate,
            backendMode: .mock,
            baseURL: URL(string: "https://api.koukou.test")!
        )

        XCTAssertEqual(container.backendMode, .mock)
        XCTAssertTrue(container.authService is MockAuthService)
        XCTAssertNil(container.apiClient)
    }

    func testDependencyContainerExplicitRemoteUsesConfiguredBaseURL() {
        let container = AppDependencyContainer(
            referenceDate: ServiceTestSupport.referenceDate,
            backendMode: .remote,
            baseURL: URL(string: "https://api.koukou.test")!
        )

        XCTAssertEqual(container.backendMode, .remote)
        XCTAssertTrue(container.authService is RemoteAuthService)
        XCTAssertEqual(container.apiClient?.baseURL.absoluteString, "https://api.koukou.test")
    }

    func testBackendConfigurationParsesOptionalBaseURL() {
        XCTAssertNil(BackendConfiguration.normalizedURL(from: nil))
        XCTAssertNil(BackendConfiguration.normalizedURL(from: ""))
        XCTAssertNil(BackendConfiguration.normalizedURL(from: "   "))
        XCTAssertNil(BackendConfiguration.normalizedURL(from: "not a url"))
        XCTAssertNil(BackendConfiguration.normalizedURL(from: "ftp://api.koukou.test"))
        XCTAssertEqual(
            BackendConfiguration.normalizedURL(from: " https://api.koukou.test/v1 ")?.absoluteString,
            "https://api.koukou.test/v1"
        )
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
            level: .level2,
            relativeTo: "2026-05-14T00:00:00Z"
        )
        XCTAssertEqual(categoryStats.path, "/books/\(bookId.uuidString)/statistics/categories")
        XCTAssertEqual(categoryStats.queryItems.map(\.name), ["scope", "type", "level", "relativeTo"])

        let categories = APIEndpoint.categories(bookId: bookId, type: .expense, includeArchived: true)
        XCTAssertEqual(categories.queryItems.map(\.name), ["type", "includeArchived"])
        XCTAssertEqual(APIEndpoint.transaction(bookId: bookId, transactionId: transactionId).method, .get)
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

    func testRemoteAuthLoginSavesTokenAndCurrentUserReturnsNilOnUnauthorized() async throws {
        let tokenStore = AuthTokenStore()
        let service = RemoteAuthService(apiClient: mockedClient(), authTokenStore: tokenStore)

        MockURLProtocol.handler = { request in
            if request.url?.path == "/auth/login" {
                return httpResponse(
                    statusCode: 200,
                    url: request.url!,
                    body: """
                    {
                      "token": "remote-token",
                      "user": {
                        "id": "00000000-0000-0000-0000-00000000A001",
                        "nickname": "Owner",
                        "email": "owner@koukou.local",
                        "createdAt": "2026-05-14T00:00:00Z",
                        "updatedAt": "2026-05-14T00:00:00Z"
                      }
                    }
                    """
                )
            }
            return httpResponse(statusCode: 401, url: request.url!, body: "{}")
        }

        let user = try await service.login(account: "owner@koukou.local", password: "password123")
        XCTAssertEqual(user.email, "owner@koukou.local")
        XCTAssertEqual(tokenStore.loadToken(), "remote-token")
        let current = try await service.currentUser()
        XCTAssertNil(current)
    }

    func testRemoteStatisticsMapsServerDeltaAndDateOnlyTrendPoint() async throws {
        let service = RemoteStatisticsService(apiClient: mockedClient())
        let bookId = UUID(uuidString: "00000000-0000-0000-0000-00000000B001")!
        var requestedPaths: [String] = []

        MockURLProtocol.handler = { request in
            requestedPaths.append(request.url?.absoluteString ?? "")
            if request.url?.path.hasSuffix("/statistics/snapshot") == true {
                return httpResponse(
                    statusCode: 200,
                    url: request.url!,
                    body: """
                    {
                      "data": {
                        "scope": "thisMonth",
                        "totalIncomeMinor": 120000,
                        "incomeDelta": { "kind": "percent", "value": 0.2 },
                        "totalExpenseMinor": 60000,
                        "expenseDelta": { "kind": "flat" },
                        "netAssetMinor": 60000,
                        "averageDailyIncomeMinor": 4000,
                        "averageDailyIncomeDelta": { "kind": "new" },
                        "averageDailyExpenseMinor": 2000,
                        "averageDailyExpenseDelta": { "kind": "percent", "value": -0.1 },
                        "currencyCode": "CNY"
                      }
                    }
                    """
                )
            }
            return httpResponse(
                statusCode: 200,
                url: request.url!,
                body: """
                {
                  "data": [
                    {
                      "id": "2026-05-14",
                      "date": "2026-05-14",
                      "incomeMinor": 120000,
                      "expenseMinor": 60000
                    }
                  ]
                }
                """
            )
        }

        let snapshot = try await service.statisticsSnapshot(
            bookId: bookId,
            scope: .thisMonth,
            relativeTo: ServiceTestSupport.referenceDate,
            requestedBy: MockSeedData.defaultUserId
        )
        XCTAssertEqual(snapshot.incomeDelta, .increased(20))
        XCTAssertEqual(snapshot.expenseDelta, .unchanged)
        XCTAssertEqual(snapshot.averageDailyIncomeDelta, .unavailable)
        XCTAssertEqual(snapshot.averageDailyExpenseDelta, .decreased(10))

        let trend = try await service.trendPoints(
            bookId: bookId,
            scope: .thisMonth,
            relativeTo: ServiceTestSupport.referenceDate,
            requestedBy: MockSeedData.defaultUserId
        )
        XCTAssertEqual(trend.first?.date, RemoteDateCoding.dateOnly.date(from: "2026-05-14"))
        XCTAssertTrue(requestedPaths.allSatisfy { $0.contains("relativeTo=") })
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

private final class MockURLProtocol: URLProtocol {
    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: APIError.unknown)
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

private func mockedClient(token: String? = nil) -> APIClient {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    return APIClient(
        baseURL: URL(string: "https://api.koukou.test")!,
        session: URLSession(configuration: configuration),
        authTokenProvider: { token }
    )
}

private func httpResponse(statusCode: Int, url: URL, body: String) -> (HTTPURLResponse, Data) {
    (
        HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!,
        Data(body.utf8)
    )
}
