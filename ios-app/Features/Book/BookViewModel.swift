import Foundation
import Combine

@MainActor
final class BookViewModel: ObservableObject {
    @Published private(set) var books: [Book] = []
    @Published private(set) var isLoading = false
    @Published var alertMessage: String?

    private let session: AppSession
    private let bookRepository: BookRepository

    init(session: AppSession) {
        self.session = session
        bookRepository = session.dependencies.bookRepository
        books = session.accessibleBooks
    }

    var currentBook: Book? {
        session.currentBook
    }

    var currentRole: BookMemberRole? {
        session.currentRole
    }

    func loadBooks() async {
        guard let userId = session.currentUser?.id else {
            books = []
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            books = try await bookRepository.fetchBooks(for: userId)
            try await session.reloadBooks()
            books = session.accessibleBooks
        } catch {
            alertMessage = message(for: error)
        }
    }

    func createBook(name: String, note: String?, defaultCurrencyCode: String) async {
        guard let userId = session.currentUser?.id else {
            alertMessage = "请先登录"
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let book = try await bookRepository.createBook(
                name: name,
                note: note,
                defaultCurrencyCode: defaultCurrencyCode,
                ownerId: userId
            )
            try await session.reloadBooks()
            try await session.selectBook(book)
            books = session.accessibleBooks
        } catch {
            alertMessage = message(for: error)
        }
    }

    func editBook(_ book: Book?, name: String, note: String?, defaultCurrencyCode: String) async {
        guard let userId = session.currentUser?.id, let book else {
            alertMessage = "请选择账本"
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let edited = Book(
                id: book.id,
                name: name,
                note: note,
                defaultCurrencyCode: defaultCurrencyCode,
                ownerId: book.ownerId,
                createdAt: book.createdAt,
                updatedAt: book.updatedAt,
                archivedAt: book.archivedAt
            )
            let updated = try await bookRepository.updateBook(edited, requestedBy: userId)
            try await session.reloadBooks()
            try await session.selectBook(updated)
            books = session.accessibleBooks
            alertMessage = nil
        } catch {
            alertMessage = message(for: error)
        }
    }

    func archiveBook(_ book: Book?) async {
        guard let userId = session.currentUser?.id, let book else {
            alertMessage = "请选择账本"
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            try await bookRepository.archiveBook(id: book.id, requestedBy: userId)
            try await session.reloadBooks()
            books = session.accessibleBooks
        } catch {
            alertMessage = message(for: error)
        }
    }

    func switchBook(_ book: Book) async {
        do {
            try await session.selectBook(book)
            books = session.accessibleBooks
        } catch {
            alertMessage = message(for: error)
        }
    }

    func canEdit(_ book: Book?) -> Bool {
        guard let userId = session.currentUser?.id, let book else {
            return false
        }
        return PermissionGuard.canManageBookSettings(userId: userId, book: book, memberRole: session.currentRole)
    }

    private func message(for error: Error) -> String {
        switch error as? AppError {
        case .permission:
            return "只有账本 Owner 可以管理账本设置"
        case .validation:
            return "请检查账本信息"
        default:
            return "账本操作失败"
        }
    }
}
