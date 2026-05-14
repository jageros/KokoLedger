import Foundation

final class AuthTokenStore {
    private var token: String?
    private let lock = NSLock()

    func saveToken(_ token: String) {
        lock.lock()
        self.token = token
        lock.unlock()
    }

    func loadToken() -> String? {
        lock.lock()
        let token = token
        lock.unlock()
        return token
    }

    func clearToken() {
        lock.lock()
        token = nil
        lock.unlock()
    }
}
