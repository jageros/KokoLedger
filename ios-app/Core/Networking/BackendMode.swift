import Foundation

enum BackendMode: Equatable {
    case mock
    case remote
}

enum BackendConfiguration {
    static let apiBaseURLKey = "KOUKOU_API_BASE_URL"

    static func configuredAPIBaseURL(bundle: Bundle = .main) -> URL? {
        normalizedURL(from: bundle.object(forInfoDictionaryKey: apiBaseURLKey) as? String)
    }

    static func normalizedURL(from rawValue: String?) -> URL? {
        guard let value = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty,
              let url = URL(string: value),
              let scheme = url.scheme,
              ["http", "https"].contains(scheme.lowercased()),
              url.host != nil else {
            return nil
        }
        return url
    }
}
