import Foundation

final class RemoteAuthService: AuthServiceProtocol {
    private let apiClient: APIClient
    private let authTokenStore: AuthTokenStore

    init(apiClient: APIClient, authTokenStore: AuthTokenStore) {
        self.apiClient = apiClient
        self.authTokenStore = authTokenStore
    }

    func login(account: String, password: String) async throws -> User {
        let response: LoginResponse = try await apiClient.post(
            .authLogin,
            body: LoginRequest(account: account, password: password)
        )
        authTokenStore.saveToken(response.token)
        return response.user
    }

    func register(email: String?, phone: String?, password: String, nickname: String) async throws -> User {
        let response: DataResponse<User> = try await apiClient.post(
            .authRegister,
            body: RegisterRequest(email: email, phone: phone, password: password, nickname: nickname)
        )
        let account = email?.isEmpty == false ? email : phone
        if let account {
            return try await login(account: account, password: password)
        }
        return response.data
    }

    func logout() async throws {
        let _: EmptyAPIResponse = try await apiClient.request(.authLogout)
        authTokenStore.clearToken()
    }

    func currentUser() async throws -> User? {
        do {
            let response: DataResponse<User> = try await apiClient.get(.authMe)
            return response.data
        } catch APIError.unauthorized {
            return nil
        }
    }

    func user(id: UUID) async throws -> User? {
        guard let current = try await currentUser(), current.id == id else {
            return nil
        }
        return current
    }
}

private struct LoginRequest: Encodable {
    let account: String
    let password: String
}

private struct RegisterRequest: Encodable {
    let email: String?
    let phone: String?
    let password: String
    let nickname: String
}

struct LoginResponse: Decodable {
    let token: String
    let user: User
}
