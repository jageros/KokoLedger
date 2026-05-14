import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int)
    case decodingFailed(Error)
    case encodingFailed(Error)
    case networkError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid API URL."
        case .invalidResponse:
            "Invalid API response."
        case .unauthorized:
            "Authentication is required."
        case .forbidden:
            "The request is forbidden."
        case .notFound:
            "The requested resource was not found."
        case let .serverError(statusCode):
            "Server error: \(statusCode)."
        case let .decodingFailed(error):
            "Failed to decode response: \(error.localizedDescription)"
        case let .encodingFailed(error):
            "Failed to encode request: \(error.localizedDescription)"
        case let .networkError(error):
            "Network error: \(error.localizedDescription)"
        case .unknown:
            "Unknown API error."
        }
    }
}
