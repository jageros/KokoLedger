import XCTest
@testable import KouKouLedger

final class BookInviteServiceTests: XCTestCase {
    func testOwnerCanCreateInvite() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        let invite = try await container.bookInviteService.createInvite(
            bookId: MockSeedData.primaryBookId,
            role: .readonly,
            requestedBy: MockSeedData.defaultUserId
        )

        XCTAssertEqual(invite.status, .pending)
    }

    func testEditorAndReadonlyCannotCreateInvite() async {
        let editorContainer = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        await XCTAssertThrowsErrorAsync {
            _ = try await editorContainer.bookInviteService.createInvite(
                bookId: MockSeedData.primaryBookId,
                role: .readonly,
                requestedBy: MockSeedData.editorUserId
            )
        }

        let readonlyContainer = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        await XCTAssertThrowsErrorAsync {
            _ = try await readonlyContainer.bookInviteService.createInvite(
                bookId: MockSeedData.primaryBookId,
                role: .readonly,
                requestedBy: MockSeedData.readonlyUserId
            )
        }
    }

    func testPendingInviteCanBeAccepted() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let invite = try await container.bookInviteService.createInvite(
            bookId: MockSeedData.primaryBookId,
            role: .readonly,
            requestedBy: MockSeedData.defaultUserId
        )
        let newUser = try await container.authService.register(
            email: "invitee@example.com",
            phone: nil,
            password: "password123",
            nickname: "受邀用户"
        )

        let member = try await container.bookInviteService.acceptInvite(
            inviteCode: invite.inviteCode,
            userId: newUser.id
        )

        XCTAssertEqual(member.userId, newUser.id)
        XCTAssertEqual(member.role, .readonly)
    }

    func testRevokedInviteCannotBeAccepted() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let invite = try await container.bookInviteService.createInvite(
            bookId: MockSeedData.primaryBookId,
            role: .readonly,
            requestedBy: MockSeedData.defaultUserId
        )
        try await container.bookInviteService.revokeInvite(
            inviteId: invite.id,
            requestedBy: MockSeedData.defaultUserId
        )

        await XCTAssertThrowsErrorAsync {
            _ = try await container.bookInviteService.acceptInvite(
                inviteCode: invite.inviteCode,
                userId: UUID()
            )
        }
    }
}
