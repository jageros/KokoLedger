import XCTest
@testable import KouKouLedger

final class BookMemberServiceTests: XCTestCase {
    func testOwnerEditorReadonlyCanViewMembers() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        XCTAssertFalse(try await container.bookMemberService.fetchMembers(
            bookId: MockSeedData.primaryBookId,
            requestedBy: MockSeedData.defaultUserId
        ).isEmpty)
        XCTAssertFalse(try await container.bookMemberService.fetchMembers(
            bookId: MockSeedData.primaryBookId,
            requestedBy: MockSeedData.editorUserId
        ).isEmpty)
        XCTAssertFalse(try await container.bookMemberService.fetchMembers(
            bookId: MockSeedData.primaryBookId,
            requestedBy: MockSeedData.readonlyUserId
        ).isEmpty)
    }

    func testNonMemberCannotViewMembers() async {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        await XCTAssertThrowsErrorAsync {
            _ = try await container.bookMemberService.fetchMembers(
                bookId: MockSeedData.primaryBookId,
                requestedBy: UUID()
            )
        }
    }

    func testOwnerCanUpdateMemberRole() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let member = try await memberForUser(MockSeedData.readonlyUserId, container: container)

        let updated = try await container.bookMemberService.updateMemberRole(
            bookId: MockSeedData.primaryBookId,
            memberId: member.id,
            role: .editor,
            requestedBy: MockSeedData.defaultUserId
        )

        XCTAssertEqual(updated.role, .editor)
    }

    func testEditorAndReadonlyCannotUpdateMemberRole() async throws {
        let editorContainer = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let editorMember = try await memberForUser(MockSeedData.readonlyUserId, container: editorContainer)
        await XCTAssertThrowsErrorAsync {
            _ = try await editorContainer.bookMemberService.updateMemberRole(
                bookId: MockSeedData.primaryBookId,
                memberId: editorMember.id,
                role: .editor,
                requestedBy: MockSeedData.editorUserId
            )
        }

        let readonlyContainer = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let readonlyMember = try await memberForUser(MockSeedData.editorUserId, container: readonlyContainer)
        await XCTAssertThrowsErrorAsync {
            _ = try await readonlyContainer.bookMemberService.updateMemberRole(
                bookId: MockSeedData.primaryBookId,
                memberId: readonlyMember.id,
                role: .readonly,
                requestedBy: MockSeedData.readonlyUserId
            )
        }
    }

    func testOwnerCannotBeRemoved() async {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        await XCTAssertThrowsErrorAsync {
            try await container.bookMemberService.removeMember(
                bookId: MockSeedData.primaryBookId,
                memberId: MockSeedData.defaultUserId,
                requestedBy: MockSeedData.defaultUserId
            )
        }
    }

    private func memberForUser(
        _ userId: UUID,
        container: AppDependencyContainer
    ) async throws -> BookMember {
        let members = try await container.bookMemberService.fetchMembers(
            bookId: MockSeedData.primaryBookId,
            requestedBy: MockSeedData.defaultUserId
        )
        return try XCTUnwrap(members.first { $0.userId == userId })
    }
}
