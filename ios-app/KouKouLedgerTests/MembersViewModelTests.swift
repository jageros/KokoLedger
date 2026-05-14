import XCTest
@testable import KouKouLedger

@MainActor
final class MembersViewModelTests: XCTestCase {
    func testOwnerCanCreateInvite() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let viewModel = MembersViewModel(session: session)

        await viewModel.createInvite(role: .editor)

        XCTAssertNotNil(viewModel.createdInvite)
        XCTAssertEqual(viewModel.createdInvite?.role, .editor)
    }

    func testEditorCannotCreateInvite() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.editorEmail, password: MockSeedData.defaultPassword)
        let viewModel = MembersViewModel(session: session)

        await viewModel.createInvite(role: .readonly)

        XCTAssertNil(viewModel.createdInvite)
        XCTAssertNotNil(viewModel.alertMessage)
    }

    func testReadonlyCannotCreateInvite() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.readonlyEmail, password: MockSeedData.defaultPassword)
        let viewModel = MembersViewModel(session: session)

        await viewModel.createInvite(role: .readonly)

        XCTAssertNil(viewModel.createdInvite)
        XCTAssertNotNil(viewModel.alertMessage)
    }

    func testAcceptInviteAddsCurrentUserToBook() async {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        let ownerSession = AppSession(dependencies: container)
        try? await ownerSession.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let ownerViewModel = MembersViewModel(session: ownerSession)
        await ownerViewModel.createInvite(role: .readonly)

        let inviteCode = ownerViewModel.createdInvite?.inviteCode ?? ""
        let inviteeSession = AppSession(dependencies: container)
        try? await inviteeSession.register(
            nickname: "受邀测试",
            email: "phase4.invitee@example.com",
            phone: nil,
            password: "password123"
        )
        let inviteeViewModel = MembersViewModel(session: inviteeSession)

        await inviteeViewModel.acceptInvite(code: inviteCode, switchToJoinedBook: true)

        XCTAssertEqual(inviteeSession.currentBook?.id, MockSeedData.primaryBookId)
    }

    func testOwnerCanUpdateMemberRole() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let viewModel = MembersViewModel(session: session)
        await viewModel.loadMembers()
        let readonlyMember = viewModel.members.first { $0.user.id == MockSeedData.readonlyUserId }

        if let readonlyMember {
            await viewModel.updateRole(for: readonlyMember.member, role: .editor)
        }

        XCTAssertEqual(
            viewModel.members.first { $0.user.id == MockSeedData.readonlyUserId }?.member.role,
            .editor
        )
    }
}
