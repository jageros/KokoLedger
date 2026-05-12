import Foundation

struct TransactionCategory: Identifiable, Codable, Equatable {
    let id: UUID
    let bookId: UUID
    let name: String
    let type: TransactionType
    let level: CategoryLevel
    let parentId: UUID?
    let icon: String?
    let colorHex: String?
    let sortOrder: Int
    let isArchived: Bool
    let createdAt: Date
    let updatedAt: Date

    var isPrimary: Bool {
        level == .level1
    }

    var isSecondary: Bool {
        level == .level2
    }

    init(
        id: UUID,
        bookId: UUID,
        name: String,
        type: TransactionType,
        level: CategoryLevel,
        parentId: UUID?,
        icon: String?,
        colorHex: String?,
        sortOrder: Int,
        isArchived: Bool,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.bookId = bookId
        self.name = name
        self.type = type
        self.level = level
        self.parentId = parentId
        self.icon = icon
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let bookId = try container.decode(UUID.self, forKey: .bookId)
        let name = try container.decode(String.self, forKey: .name)
        let type = try container.decode(TransactionType.self, forKey: .type)
        let level = try container.decode(CategoryLevel.self, forKey: .level)
        let parentId = try container.decodeIfPresent(UUID.self, forKey: .parentId)
        let icon = try container.decodeIfPresent(String.self, forKey: .icon)
        let colorHex = try container.decodeIfPresent(String.self, forKey: .colorHex)
        let sortOrder = try container.decode(Int.self, forKey: .sortOrder)
        let isArchived = try container.decode(Bool.self, forKey: .isArchived)
        let createdAt = try container.decode(Date.self, forKey: .createdAt)
        let updatedAt = try container.decode(Date.self, forKey: .updatedAt)

        guard Self.isValidParent(level: level, parentId: parentId) else {
            throw DecodingError.dataCorruptedError(
                forKey: .parentId,
                in: container,
                debugDescription: "TransactionCategory parentId must be nil for level1 and non-nil for level2."
            )
        }

        self.init(
            id: id,
            bookId: bookId,
            name: name,
            type: type,
            level: level,
            parentId: parentId,
            icon: icon,
            colorHex: colorHex,
            sortOrder: sortOrder,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    private static func isValidParent(level: CategoryLevel, parentId: UUID?) -> Bool {
        switch level {
        case .level1:
            parentId == nil
        case .level2:
            parentId != nil
        }
    }
}
