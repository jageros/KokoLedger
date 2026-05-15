import Foundation

final class APIClient {
    let baseURL: URL

    private let session: URLSession
    private let authTokenProvider: () async -> String?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        session: URLSession = .shared,
        authTokenProvider: @escaping () async -> String? = { nil }
    ) {
        self.baseURL = baseURL
        self.session = session
        self.authTokenProvider = authTokenProvider

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func makeURLRequest(_ endpoint: APIEndpoint) async throws -> URLRequest {
        try await makeURLRequest(endpoint, body: Optional<EmptyRequestBody>.none)
    }

    func makeURLRequest<Body: Encodable>(_ endpoint: APIEndpoint, body: Body?) async throws -> URLRequest {
        let url = try makeURL(for: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = await authTokenProvider(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            do {
                request.httpBody = try encoder.encode(body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw APIError.encodingFailed(error)
            }
        }

        return request
    }

    func request<Response: Decodable>(_ endpoint: APIEndpoint) async throws -> Response {
        let request = try await makeURLRequest(endpoint)
        return try await send(request)
    }

    func request<Body: Encodable, Response: Decodable>(
        _ endpoint: APIEndpoint,
        body: Body
    ) async throws -> Response {
        let request = try await makeURLRequest(endpoint, body: body)
        return try await send(request)
    }

    func get<Response: Decodable>(_ endpoint: APIEndpoint) async throws -> Response {
        try await request(endpoint)
    }

    func post<Body: Encodable, Response: Decodable>(_ endpoint: APIEndpoint, body: Body) async throws -> Response {
        try await request(endpoint, body: body)
    }

    func patch<Body: Encodable, Response: Decodable>(_ endpoint: APIEndpoint, body: Body) async throws -> Response {
        try await request(endpoint, body: body)
    }

    func delete<Response: Decodable>(_ endpoint: APIEndpoint) async throws -> Response {
        try await request(endpoint)
    }

    private func makeURL(for endpoint: APIEndpoint) throws -> URL {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }

        let basePath = baseURL.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let endpointPath = endpoint.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components.path = "/" + [basePath, endpointPath]
            .filter { !$0.isEmpty }
            .joined(separator: "/")
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        return url
    }

    private func send<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200..<300:
            do {
                return try decoder.decode(Response.self, from: data)
            } catch {
                throw APIError.decodingFailed(error)
            }
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 500..<600:
            throw APIError.serverError(httpResponse.statusCode)
        default:
            throw APIError.unknown
        }
    }

    private struct EmptyRequestBody: Encodable {}
}

struct DataResponse<Value: Decodable>: Decodable {
    let data: Value
}

struct EmptyAPIResponse: Decodable {}

enum RemoteDateCoding {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let fallbackISO8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static let dateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func string(from date: Date) -> String {
        fallbackISO8601.string(from: date)
    }

    static func date(from value: String) throws -> Date {
        if let date = iso8601.date(from: value) ?? fallbackISO8601.date(from: value) ?? dateOnly.date(from: value) {
            return date
        }
        throw APIError.decodingFailed(
            DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: [], debugDescription: "Invalid remote date: \(value)")
            )
        )
    }
}
