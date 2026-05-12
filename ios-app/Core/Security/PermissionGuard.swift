import Foundation

enum PermissionGuard {
    static func isOwner(userId: UUID, book: Book) -> Bool {
        userId == book.ownerId
    }

    static func canViewBook(userId: UUID, book: Book, memberRole: BookMemberRole?) -> Bool {
        isOwner(userId: userId, book: book) || memberRole != nil
    }

    static func canViewStatistics(userId: UUID, book: Book, memberRole: BookMemberRole?) -> Bool {
        canViewBook(userId: userId, book: book, memberRole: memberRole)
    }

    static func canCreateTransaction(userId: UUID, book: Book, memberRole: BookMemberRole?) -> Bool {
        canWriteTransactions(userId: userId, book: book, memberRole: memberRole)
    }

    static func canEditTransaction(userId: UUID, book: Book, memberRole: BookMemberRole?) -> Bool {
        canWriteTransactions(userId: userId, book: book, memberRole: memberRole)
    }

    static func canDeleteTransaction(userId: UUID, book: Book, memberRole: BookMemberRole?) -> Bool {
        canWriteTransactions(userId: userId, book: book, memberRole: memberRole)
    }

    static func canManageCategories(userId: UUID, book: Book, memberRole: BookMemberRole?) -> Bool {
        canWriteTransactions(userId: userId, book: book, memberRole: memberRole)
    }

    static func canManageBookSettings(userId: UUID, book: Book, memberRole: BookMemberRole?) -> Bool {
        isOwner(userId: userId, book: book)
    }

    static func canInviteMember(userId: UUID, book: Book, memberRole: BookMemberRole?) -> Bool {
        isOwner(userId: userId, book: book)
    }

    static func canUpdateMemberRole(userId: UUID, book: Book, memberRole: BookMemberRole?) -> Bool {
        isOwner(userId: userId, book: book)
    }

    static func canRemoveMember(userId: UUID, book: Book, memberRole: BookMemberRole?) -> Bool {
        isOwner(userId: userId, book: book)
    }

    static func canArchiveBook(userId: UUID, book: Book, memberRole: BookMemberRole?) -> Bool {
        isOwner(userId: userId, book: book)
    }

    static func canDeleteBook(userId: UUID, book: Book, memberRole: BookMemberRole?) -> Bool {
        isOwner(userId: userId, book: book)
    }

    static func assertCanCreateTransaction(userId: UUID, book: Book, memberRole: BookMemberRole?) throws {
        try assertAllowed(canCreateTransaction(userId: userId, book: book, memberRole: memberRole))
    }

    static func assertCanEditTransaction(userId: UUID, book: Book, memberRole: BookMemberRole?) throws {
        try assertAllowed(canEditTransaction(userId: userId, book: book, memberRole: memberRole))
    }

    static func assertCanDeleteTransaction(userId: UUID, book: Book, memberRole: BookMemberRole?) throws {
        try assertAllowed(canDeleteTransaction(userId: userId, book: book, memberRole: memberRole))
    }

    static func assertCanManageCategories(userId: UUID, book: Book, memberRole: BookMemberRole?) throws {
        try assertAllowed(canManageCategories(userId: userId, book: book, memberRole: memberRole))
    }

    static func assertCanInviteMember(userId: UUID, book: Book, memberRole: BookMemberRole?) throws {
        try assertAllowed(canInviteMember(userId: userId, book: book, memberRole: memberRole))
    }

    static func assertCanUpdateMemberRole(userId: UUID, book: Book, memberRole: BookMemberRole?) throws {
        try assertAllowed(canUpdateMemberRole(userId: userId, book: book, memberRole: memberRole))
    }

    static func assertCanRemoveMember(userId: UUID, book: Book, memberRole: BookMemberRole?) throws {
        try assertAllowed(canRemoveMember(userId: userId, book: book, memberRole: memberRole))
    }

    private static func canWriteTransactions(userId: UUID, book: Book, memberRole: BookMemberRole?) -> Bool {
        if isOwner(userId: userId, book: book) {
            return true
        }

        return memberRole == .editor
    }

    private static func assertAllowed(_ allowed: Bool) throws {
        guard allowed else {
            throw AppError.permission
        }
    }
}
