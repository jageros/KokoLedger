import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var account = ""
    @Published var password = ""
    @Published var nickname = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var confirmPassword = ""
    @Published private(set) var isLoading = false
    @Published var alertMessage: String?

    private let session: AppSession

    init(session: AppSession) {
        self.session = session
    }

    func login() async {
        guard !isLoading else { return }
        do {
            try validateLogin()
            isLoading = true
            defer { isLoading = false }
            try await session.login(
                account: account.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
        } catch {
            alertMessage = message(for: error)
            isLoading = false
        }
    }

    func register() async {
        guard !isLoading else { return }
        do {
            try validateRegister()
            isLoading = true
            defer { isLoading = false }
            try await session.register(
                nickname: nickname.trimmingCharacters(in: .whitespacesAndNewlines),
                email: normalized(email),
                phone: normalized(phone),
                password: password
            )
        } catch {
            alertMessage = message(for: error)
            isLoading = false
        }
    }

    private func validateLogin() throws {
        let trimmedAccount = account.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAccount.isEmpty, !password.isEmpty else {
            throw AppError.validation
        }
    }

    private func validateRegister() throws {
        guard ValidationUtils.isValidNickname(nickname) else {
            throw AppError.validation
        }

        let normalizedEmail = normalized(email)
        let normalizedPhone = normalized(phone)
        guard normalizedEmail != nil || normalizedPhone != nil else {
            throw AppError.validation
        }
        if let normalizedEmail, !ValidationUtils.isValidEmail(normalizedEmail) {
            throw AppError.validation
        }
        if let normalizedPhone, !ValidationUtils.isValidPhone(normalizedPhone) {
            throw AppError.validation
        }
        guard password.count >= 6, password == confirmPassword else {
            throw AppError.validation
        }
    }

    private func normalized(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func message(for error: Error) -> String {
        switch error as? AppError {
        case .auth:
            return "账号或密码不正确"
        case .permission:
            return "当前账号没有权限"
        case .validation:
            return "请检查表单内容"
        case .data:
            return "数据异常，请稍后重试"
        case .network:
            return "网络异常，请稍后重试"
        case .unknown, .none:
            return "操作失败，请稍后重试"
        }
    }
}
