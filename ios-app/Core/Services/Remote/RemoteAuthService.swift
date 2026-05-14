import Foundation

final class RemoteAuthService: AuthServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func login(account: String, password: String) async throws -> User {
        throw unavailable()
    }

    func register(email: String?, phone: String?, password: String, nickname: String) async throws -> User {
        throw unavailable()
    }

    func logout() async throws {
        throw unavailable()
    }

    func currentUser() async throws -> User? {
        throw unavailable()
    }

    func user(id: UUID) async throws -> User? {
        throw unavailable()
    }

    private func unavailable() -> AppError {
        _ = apiClient
        return .network
    }
}
