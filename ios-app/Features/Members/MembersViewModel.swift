import Foundation
import Combine

struct BookMemberDisplay: Identifiable, Equatable {
    let member: BookMember
    let user: User

    var id: UUID {
        member.id
    }
}

@MainActor
final class MembersViewModel: ObservableObject {
    @Published private(set) var members: [BookMemberDisplay] = []
    @Published private(set) var createdInvite: BookInvite?
    @Published private(set) var isLoading = false
    @Published var alertMessage: String?
    @Published var inviteCode = ""

    private let session: AppSession
    private let authRepository: AuthRepository
    private let bookRepository: BookRepository
    private let memberRepository: BookMemberRepository
    private let inviteRepository: BookInviteRepository

    init(session: AppSession) {
        self.session = session
        authRepository = session.dependencies.authRepository
        bookRepository = session.dependencies.bookRepository
        memberRepository = session.dependencies.bookMemberRepository
        inviteRepository = session.dependencies.bookInviteRepository
    }

    var canManageMembers: Bool {
        guard let userId = session.currentUser?.id, let book = session.currentBook else {
            return false
        }
        return PermissionGuard.canInviteMember(userId: userId, book: book, memberRole: session.currentRole)
    }

    func loadMembers() async {
        guard let userId = session.currentUser?.id, let book = session.currentBook else {
            members = []
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let rawMembers = try await memberRepository.fetchMembers(bookId: book.id, requestedBy: userId)
            var display: [BookMemberDisplay] = []
            for member in rawMembers {
                if let user = try await authRepository.user(id: member.userId) {
                    display.append(BookMemberDisplay(member: member, user: user))
                }
            }
            members = display
        } catch {
            alertMessage = message(for: error)
        }
    }

    func createInvite(role: BookMemberRole) async {
        guard let userId = session.currentUser?.id, let book = session.currentBook else {
            alertMessage = "请选择账本"
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            createdInvite = try await inviteRepository.createInvite(bookId: book.id, role: role, requestedBy: userId)
        } catch {
            alertMessage = message(for: error)
        }
    }

    func acceptInvite(code: String, switchToJoinedBook: Bool) async {
        guard let userId = session.currentUser?.id else {
            alertMessage = "请先登录"
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let member = try await inviteRepository.acceptInvite(inviteCode: code, userId: userId)
            try await session.reloadBooks()
            if switchToJoinedBook,
               let joinedBook = try await bookRepository.fetchBook(id: member.bookId, userId: userId) {
                try await session.selectBook(joinedBook)
            }
        } catch {
            alertMessage = message(for: error)
        }
    }

    func revokeInvite(_ invite: BookInvite) async {
        guard let userId = session.currentUser?.id else {
            alertMessage = "请先登录"
            return
        }
        do {
            try await inviteRepository.revokeInvite(inviteId: invite.id, requestedBy: userId)
            createdInvite = nil
        } catch {
            alertMessage = message(for: error)
        }
    }

    func updateRole(for member: BookMember, role: BookMemberRole) async {
        guard let userId = session.currentUser?.id, let book = session.currentBook else {
            alertMessage = "请选择账本"
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await memberRepository.updateMemberRole(
                bookId: book.id,
                memberId: member.id,
                role: role,
                requestedBy: userId
            )
            await loadMembers()
        } catch {
            alertMessage = message(for: error)
        }
    }

    func removeMember(_ member: BookMember) async {
        guard let userId = session.currentUser?.id, let book = session.currentBook else {
            alertMessage = "请选择账本"
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            try await memberRepository.removeMember(bookId: book.id, memberId: member.id, requestedBy: userId)
            await loadMembers()
        } catch {
            alertMessage = message(for: error)
        }
    }

    private func message(for error: Error) -> String {
        switch error as? AppError {
        case .permission:
            return "只有账本 Owner 可以管理成员"
        case .validation:
            return "邀请码不可用"
        default:
            return "成员操作失败"
        }
    }
}
