import Foundation

enum PercentageDelta: Codable, Equatable {
    case unavailable
    case zero
    case increased(Double)
    case decreased(Double)
    case unchanged

    private enum CodingKeys: String, CodingKey {
        case kind
        case value
    }

    private enum Kind: String, Codable {
        case unavailable
        case zero
        case increased
        case decreased
        case unchanged
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)

        switch kind {
        case .unavailable:
            self = .unavailable
        case .zero:
            self = .zero
        case .increased:
            self = .increased(try container.decode(Double.self, forKey: .value))
        case .decreased:
            self = .decreased(try container.decode(Double.self, forKey: .value))
        case .unchanged:
            self = .unchanged
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .unavailable:
            try container.encode(Kind.unavailable, forKey: .kind)
        case .zero:
            try container.encode(Kind.zero, forKey: .kind)
        case let .increased(value):
            try container.encode(Kind.increased, forKey: .kind)
            try container.encode(value, forKey: .value)
        case let .decreased(value):
            try container.encode(Kind.decreased, forKey: .kind)
            try container.encode(value, forKey: .value)
        case .unchanged:
            try container.encode(Kind.unchanged, forKey: .kind)
        }
    }
}
