import XCTest
@testable import KouKouLedger

final class AuthServiceTests: XCTestCase {
    func testDefaultUserCanLogin() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        let user = try await container.authService.login(
            account: MockSeedData.defaultEmail,
            password: MockSeedData.defaultPassword
        )

        XCTAssertEqual(user.id, MockSeedData.defaultUserId)
    }

    func testWrongPasswordLoginFails() async {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        await XCTAssertThrowsErrorAsync {
            _ = try await container.authService.login(
                account: MockSeedData.defaultEmail,
                password: "wrong-password"
            )
        }
    }

    func testRegisterUserSucceeds() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)

        let user = try await container.authService.register(
            email: "new.user@example.com",
            phone: nil,
            password: "password123",
            nickname: "新用户"
        )

        XCTAssertEqual(user.email, "new.user@example.com")
        XCTAssertEqual(try await container.authService.currentUser(), user)
    }

    func testLogoutClearsCurrentUser() async throws {
        let container = AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate)
        _ = try await container.authService.login(
            account: MockSeedData.defaultEmail,
            password: MockSeedData.defaultPassword
        )

        try await container.authService.logout()

        XCTAssertNil(try await container.authService.currentUser())
    }
}
