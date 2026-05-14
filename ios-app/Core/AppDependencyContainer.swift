import Foundation

final class AppDependencyContainer {
    let backendMode: BackendMode
    let store: MockDataStore
    let apiClient: APIClient?
    let authTokenStore: AuthTokenStore
    let localCacheService: LocalCacheServiceProtocol

    let authService: AuthServiceProtocol
    let bookService: BookServiceProtocol
    let bookMemberService: BookMemberServiceProtocol
    let bookInviteService: BookInviteServiceProtocol
    let categoryService: CategoryServiceProtocol
    let transactionService: TransactionServiceProtocol
    let statisticsService: StatisticsServiceProtocol

    let authRepository: AuthRepository
    let bookRepository: BookRepository
    let bookMemberRepository: BookMemberRepository
    let bookInviteRepository: BookInviteRepository
    let categoryRepository: CategoryRepository
    let transactionRepository: TransactionRepository
    let statisticsRepository: StatisticsRepository

    init(
        referenceDate: Date = Date(),
        backendMode: BackendMode = .mock,
        baseURL: URL = URL(string: "https://api.koukou.local")!,
        authTokenStore: AuthTokenStore = AuthTokenStore(),
        localCacheService: LocalCacheServiceProtocol = SwiftDataLocalCacheService()
    ) {
        self.backendMode = backendMode
        self.authTokenStore = authTokenStore
        self.localCacheService = localCacheService

        let store = MockDataStore(referenceDate: referenceDate)
        self.store = store

        let authService: AuthServiceProtocol
        let bookService: BookServiceProtocol
        let bookMemberService: BookMemberServiceProtocol
        let bookInviteService: BookInviteServiceProtocol
        let categoryService: CategoryServiceProtocol
        let transactionService: TransactionServiceProtocol
        let statisticsService: StatisticsServiceProtocol

        switch backendMode {
        case .mock:
            apiClient = nil
            authService = MockAuthService(store: store)
            bookService = MockBookService(store: store)
            bookMemberService = MockBookMemberService(store: store)
            bookInviteService = MockBookInviteService(store: store)
            categoryService = MockCategoryService(store: store)
            transactionService = MockTransactionService(store: store)
            statisticsService = MockStatisticsService(store: store)
        case .remote:
            let apiClient = APIClient(
                baseURL: baseURL,
                authTokenProvider: {
                    authTokenStore.loadToken()
                }
            )
            self.apiClient = apiClient
            authService = RemoteAuthService(apiClient: apiClient)
            bookService = RemoteBookService(apiClient: apiClient)
            bookMemberService = RemoteBookMemberService(apiClient: apiClient)
            bookInviteService = RemoteBookInviteService(apiClient: apiClient)
            categoryService = RemoteCategoryService(apiClient: apiClient)
            transactionService = RemoteTransactionService(apiClient: apiClient)
            statisticsService = RemoteStatisticsService(apiClient: apiClient)
        }

        self.authService = authService
        self.bookService = bookService
        self.bookMemberService = bookMemberService
        self.bookInviteService = bookInviteService
        self.categoryService = categoryService
        self.transactionService = transactionService
        self.statisticsService = statisticsService

        authRepository = AuthRepository(service: authService)
        bookRepository = BookRepository(service: bookService)
        bookMemberRepository = BookMemberRepository(service: bookMemberService)
        bookInviteRepository = BookInviteRepository(service: bookInviteService)
        categoryRepository = CategoryRepository(service: categoryService)
        transactionRepository = TransactionRepository(service: transactionService)
        statisticsRepository = StatisticsRepository(service: statisticsService)
    }
}
