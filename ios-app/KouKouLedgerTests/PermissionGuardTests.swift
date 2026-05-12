import XCTest
@testable import KouKouLedger

final class PermissionGuardTests: XCTestCase {
    private let ownerId = UUID()
    private let editorId = UUID()
    private let readonlyId = UUID()
    private let outsiderId = UUID()

    func testOwnerPermissions() {
        let book = makeBook(ownerId: ownerId)

        XCTAssertTrue(PermissionGuard.canViewBook(userId: ownerId, book: book, memberRole: nil))
        XCTAssertTrue(PermissionGuard.canViewStatistics(userId: ownerId, book: book, memberRole: nil))
        XCTAssertTrue(PermissionGuard.canCreateTransaction(userId: ownerId, book: book, memberRole: nil))
        XCTAssertTrue(PermissionGuard.canEditTransaction(userId: ownerId, book: book, memberRole: nil))
        XCTAssertTrue(PermissionGuard.canDeleteTransaction(userId: ownerId, book: book, memberRole: nil))
        XCTAssertTrue(PermissionGuard.canManageCategories(userId: ownerId, book: book, memberRole: nil))
        XCTAssertTrue(PermissionGuard.canInviteMember(userId: ownerId, book: book, memberRole: nil))
        XCTAssertTrue(PermissionGuard.canUpdateMemberRole(userId: ownerId, book: book, memberRole: nil))
        XCTAssertTrue(PermissionGuard.canRemoveMember(userId: ownerId, book: book, memberRole: nil))
        XCTAssertTrue(PermissionGuard.canArchiveBook(userId: ownerId, book: book, memberRole: nil))
        XCTAssertTrue(PermissionGuard.canDeleteBook(userId: ownerId, book: book, memberRole: nil))
    }

    func testEditorPermissions() {
        let book = makeBook(ownerId: ownerId)

        XCTAssertTrue(PermissionGuard.canViewBook(userId: editorId, book: book, memberRole: .editor))
        XCTAssertTrue(PermissionGuard.canViewStatistics(userId: editorId, book: book, memberRole: .editor))
        XCTAssertTrue(PermissionGuard.canCreateTransaction(userId: editorId, book: book, memberRole: .editor))
        XCTAssertTrue(PermissionGuard.canEditTransaction(userId: editorId, book: book, memberRole: .editor))
        XCTAssertTrue(PermissionGuard.canDeleteTransaction(userId: editorId, book: book, memberRole: .editor))
        XCTAssertTrue(PermissionGuard.canManageCategories(userId: editorId, book: book, memberRole: .editor))
        XCTAssertFalse(PermissionGuard.canInviteMember(userId: editorId, book: book, memberRole: .editor))
        XCTAssertFalse(PermissionGuard.canUpdateMemberRole(userId: editorId, book: book, memberRole: .editor))
        XCTAssertFalse(PermissionGuard.canRemoveMember(userId: editorId, book: book, memberRole: .editor))
        XCTAssertFalse(PermissionGuard.canArchiveBook(userId: editorId, book: book, memberRole: .editor))
    }

    func testReadonlyPermissions() {
        let book = makeBook(ownerId: ownerId)

        XCTAssertTrue(PermissionGuard.canViewBook(userId: readonlyId, book: book, memberRole: .readonly))
        XCTAssertTrue(PermissionGuard.canViewStatistics(userId: readonlyId, book: book, memberRole: .readonly))
        XCTAssertFalse(PermissionGuard.canCreateTransaction(userId: readonlyId, book: book, memberRole: .readonly))
        XCTAssertFalse(PermissionGuard.canEditTransaction(userId: readonlyId, book: book, memberRole: .readonly))
        XCTAssertFalse(PermissionGuard.canDeleteTransaction(userId: readonlyId, book: book, memberRole: .readonly))
        XCTAssertFalse(PermissionGuard.canManageCategories(userId: readonlyId, book: book, memberRole: .readonly))
        XCTAssertFalse(PermissionGuard.canInviteMember(userId: readonlyId, book: book, memberRole: .readonly))
    }

    func testNonMemberCannotViewBook() {
        let book = makeBook(ownerId: ownerId)

        XCTAssertFalse(PermissionGuard.canViewBook(userId: outsiderId, book: book, memberRole: nil))
    }

    func testAssertCreateTransactionThrowsForReadonly() {
        let book = makeBook(ownerId: ownerId)

        XCTAssertThrowsError(
            try PermissionGuard.assertCanCreateTransaction(userId: readonlyId, book: book, memberRole: .readonly)
        )
    }

    func testAssertInviteMemberThrowsForEditor() {
        let book = makeBook(ownerId: ownerId)

        XCTAssertThrowsError(
            try PermissionGuard.assertCanInviteMember(userId: editorId, book: book, memberRole: .editor)
        )
    }

    private func makeBook(ownerId: UUID) -> Book {
        Book(
            id: UUID(),
            name: "家庭账本",
            note: nil,
            defaultCurrencyCode: "CNY",
            ownerId: ownerId,
            createdAt: Date(),
            updatedAt: Date(),
            archivedAt: nil
        )
    }
}
