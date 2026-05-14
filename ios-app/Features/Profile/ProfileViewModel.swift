import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: User?
    @Published private(set) var book: Book?
    @Published private(set) var role: BookMemberRole?
    @Published private(set) var summary: LedgerSummary?
    @Published private(set) var isLoading = false
    @Published var alertMessage: String?

    private let session: AppSession
    private let statisticsRepository: StatisticsRepository

    init(session: AppSession) {
        self.session = session
        statisticsRepository = session.dependencies.statisticsRepository
    }

    var roleTitle: String {
        session.roleTitle()
    }

    func load() async {
        user = session.currentUser
        book = session.currentBook
        role = session.currentRole
        guard let userId = user?.id, let book else {
            summary = nil
            return
        }

        isLoading = true
        defer { isLoading = false }
        do {
            summary = try await statisticsRepository.ledgerSummary(bookId: book.id, requestedBy: userId)
        } catch {
            alertMessage = "账本汇总加载失败"
        }
    }

    func logout() async {
        await session.logout()
    }
}
