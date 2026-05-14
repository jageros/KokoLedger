import XCTest
@testable import KouKouLedger

@MainActor
final class AuthViewModelTests: XCTestCase {
    func testLoginSuccessAuthenticatesSession() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        let viewModel = AuthViewModel(session: session)
        viewModel.account = MockSeedData.defaultEmail
        viewModel.password = MockSeedData.defaultPassword

        await viewModel.login()

        XCTAssertTrue(session.isAuthenticated)
        XCTAssertEqual(session.currentUser?.id, MockSeedData.defaultUserId)
    }

    func testLoginFailureShowsError() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        let viewModel = AuthViewModel(session: session)
        viewModel.account = MockSeedData.defaultEmail
        viewModel.password = "wrong-password"

        await viewModel.login()

        XCTAssertFalse(session.isAuthenticated)
        XCTAssertNotNil(viewModel.alertMessage)
    }

    func testRegisterValidationFailureDoesNotAuthenticate() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        let viewModel = AuthViewModel(session: session)
        viewModel.nickname = ""
        viewModel.email = ""
        viewModel.phone = ""
        viewModel.password = "123"
        viewModel.confirmPassword = "456"

        await viewModel.register()

        XCTAssertFalse(session.isAuthenticated)
        XCTAssertNotNil(viewModel.alertMessage)
    }

    func testRegisterSuccessAuthenticatesSession() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        let viewModel = AuthViewModel(session: session)
        viewModel.nickname = "新成员"
        viewModel.email = "phase4.user@example.com"
        viewModel.phone = ""
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"

        await viewModel.register()

        XCTAssertTrue(session.isAuthenticated)
        XCTAssertEqual(session.currentUser?.email, "phase4.user@example.com")
    }
}
