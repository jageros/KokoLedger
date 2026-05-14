import Foundation
import Combine

@MainActor
final class AppSession: ObservableObject {
    let dependencies: AppDependencyContainer

    @Published private(set) var currentUser: User?
    @Published private(set) var currentBook: Book?
    @Published private(set) var currentRole: BookMemberRole?
    @Published private(set) var accessibleBooks: [Book] = []
    @Published private(set) var isBootstrapping = true

    init(dependencies: AppDependencyContainer = AppDependencyContainer()) {
        self.dependencies = dependencies
    }

    var isAuthenticated: Bool {
        currentUser != nil
    }

    var currentMemberRole: BookMemberRole? {
        currentRole
    }

    var isCurrentUserOwner: Bool {
        guard let userId = currentUser?.id, let book = currentBook else {
            return false
        }
        return book.ownerId == userId
    }

    func bootstrap() async {
        isBootstrapping = true
        defer { isBootstrapping = false }
        do {
            currentUser = try await dependencies.authRepository.currentUser()
            if currentUser != nil {
                try await reloadBooks()
            }
        } catch {
            clearAuthenticatedState()
        }
    }

    func login(account: String, password: String) async throws {
        currentUser = try await dependencies.authRepository.login(account: account, password: password)
        try await reloadBooks()
    }

    func register(nickname: String, email: String?, phone: String?, password: String) async throws {
        currentUser = try await dependencies.authRepository.register(
            email: email,
            phone: phone,
            password: password,
            nickname: nickname
        )
        try await reloadBooks()
    }

    func logout() async {
        try? await dependencies.authRepository.logout()
        clearAuthenticatedState()
    }

    func reloadBooks() async throws {
        guard let userId = currentUser?.id else {
            accessibleBooks = []
            currentBook = nil
            currentRole = nil
            return
        }

        let books = try await dependencies.bookRepository.fetchBooks(for: userId)
        accessibleBooks = books

        if let selected = currentBook, books.contains(where: { $0.id == selected.id }) {
            currentBook = books.first { $0.id == selected.id }
        } else {
            currentBook = books.first
        }
        try await refreshCurrentRole()
    }

    func selectBook(_ book: Book) async throws {
        guard let userId = currentUser?.id,
              let accessibleBook = try await dependencies.bookRepository.fetchBook(id: book.id, userId: userId) else {
            throw AppError.permission
        }
        currentBook = accessibleBook
        try await refreshCurrentRole()
    }

    func setCurrentBook(_ book: Book?) async {
        currentBook = book
        try? await refreshCurrentRole()
    }

    func refreshCurrentRole() async throws {
        guard let userId = currentUser?.id, let book = currentBook else {
            currentRole = nil
            return
        }
        if book.ownerId == userId {
            currentRole = nil
            return
        }
        let members = try await dependencies.bookMemberRepository.fetchMembers(bookId: book.id, requestedBy: userId)
        currentRole = members.first { $0.userId == userId }?.role
    }

    func roleTitle(for book: Book? = nil) -> String {
        guard let userId = currentUser?.id, let book = book ?? currentBook else {
            return "无账本"
        }
        if book.ownerId == userId {
            return "Owner"
        }
        switch currentRole {
        case .editor:
            return "Editor"
        case .readonly:
            return "Readonly"
        case .none:
            return "无权限"
        }
    }

    private func clearAuthenticatedState() {
        currentUser = nil
        currentBook = nil
        currentRole = nil
        accessibleBooks = []
    }
}
