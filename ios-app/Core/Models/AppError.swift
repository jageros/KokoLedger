import Foundation

enum AppError: LocalizedError, Equatable {
    case auth
    case permission
    case validation
    case data
    case network
    case unknown

    var errorDescription: String? {
        switch self {
        case .auth:
            "Authentication failed."
        case .permission:
            "Permission denied."
        case .validation:
            "Validation failed."
        case .data:
            "Data error."
        case .network:
            "Network error."
        case .unknown:
            "Unknown error."
        }
    }
}
