import Foundation

final class MockDataStore {
    var users: [UUID: User]
    var passwords: [UUID: String]
    var currentUserId: UUID?
    var books: [UUID: Book]
    var members: [UUID: BookMember]
    var invites: [UUID: BookInvite]
    var categories: [UUID: TransactionCategory]
    var transactions: [UUID: LedgerTransaction]

    private let referenceDate: Date

    init(referenceDate: Date = Date()) {
        self.referenceDate = referenceDate

        let owner = User(
            id: MockSeedData.defaultUserId,
            nickname: "账本主人",
            avatarURL: nil,
            email: MockSeedData.defaultEmail,
            phone: MockSeedData.defaultPhone,
            createdAt: referenceDate,
            updatedAt: referenceDate
        )
        let editor = User(
            id: MockSeedData.editorUserId,
            nickname: "可编辑成员",
            avatarURL: nil,
            email: MockSeedData.editorEmail,
            phone: MockSeedData.editorPhone,
            createdAt: referenceDate,
            updatedAt: referenceDate
        )
        let readonly = User(
            id: MockSeedData.readonlyUserId,
            nickname: "只读成员",
            avatarURL: nil,
            email: MockSeedData.readonlyEmail,
            phone: MockSeedData.readonlyPhone,
            createdAt: referenceDate,
            updatedAt: referenceDate
        )

        users = [owner.id: owner, editor.id: editor, readonly.id: readonly]
        passwords = [
            owner.id: MockSeedData.defaultPassword,
            editor.id: MockSeedData.defaultPassword,
            readonly.id: MockSeedData.defaultPassword
        ]

        let book = Book(
            id: MockSeedData.primaryBookId,
            name: "家庭账本",
            note: "一家人的日常收支",
            defaultCurrencyCode: "CNY",
            ownerId: owner.id,
            createdAt: referenceDate.addingTimeInterval(-86_400 * 30),
            updatedAt: referenceDate,
            archivedAt: nil
        )
        books = [book.id: book]

        let seededMembers = [
            BookMember(
                id: MockSeedData.ownerMemberId,
                bookId: book.id,
                userId: owner.id,
                role: .editor,
                joinedAt: book.createdAt
            ),
            BookMember(
                id: MockSeedData.editorMemberId,
                bookId: book.id,
                userId: editor.id,
                role: .editor,
                joinedAt: referenceDate.addingTimeInterval(-86_400 * 15)
            ),
            BookMember(
                id: MockSeedData.readonlyMemberId,
                bookId: book.id,
                userId: readonly.id,
                role: .readonly,
                joinedAt: referenceDate.addingTimeInterval(-86_400 * 7)
            )
        ]
        members = Dictionary(uniqueKeysWithValues: seededMembers.map { ($0.id, $0) })

        let seededCategories = [
            TransactionCategory(
                id: MockSeedData.expenseFoodCategoryId,
                bookId: book.id,
                name: "餐饮",
                type: .expense,
                level: .level1,
                parentId: nil,
                icon: "fork.knife",
                colorHex: "#FF9500",
                sortOrder: 0,
                isArchived: false,
                createdAt: referenceDate,
                updatedAt: referenceDate
            ),
            TransactionCategory(
                id: MockSeedData.expenseCoffeeCategoryId,
                bookId: book.id,
                name: "咖啡",
                type: .expense,
                level: .level2,
                parentId: MockSeedData.expenseFoodCategoryId,
                icon: "cup.and.saucer",
                colorHex: "#A2845E",
                sortOrder: 0,
                isArchived: false,
                createdAt: referenceDate,
                updatedAt: referenceDate
            ),
            TransactionCategory(
                id: MockSeedData.incomeSalaryCategoryId,
                bookId: book.id,
                name: "工资",
                type: .income,
                level: .level1,
                parentId: nil,
                icon: "briefcase",
                colorHex: "#34C759",
                sortOrder: 1,
                isArchived: false,
                createdAt: referenceDate,
                updatedAt: referenceDate
            ),
            TransactionCategory(
                id: MockSeedData.incomeBonusCategoryId,
                bookId: book.id,
                name: "奖金",
                type: .income,
                level: .level2,
                parentId: MockSeedData.incomeSalaryCategoryId,
                icon: "gift",
                colorHex: "#30B0C7",
                sortOrder: 1,
                isArchived: false,
                createdAt: referenceDate,
                updatedAt: referenceDate
            )
        ]
        categories = Dictionary(uniqueKeysWithValues: seededCategories.map { ($0.id, $0) })

        let seededTransactions = [
            LedgerTransaction(
                id: UUID(),
                bookId: book.id,
                type: .income,
                amountMinor: 18_000_00,
                currencyCode: "CNY",
                categoryLevel1Id: MockSeedData.incomeSalaryCategoryId,
                categoryLevel2Id: MockSeedData.incomeBonusCategoryId,
                occurredAt: referenceDate.addingTimeInterval(-86_400 * 2),
                note: "工资",
                createdBy: owner.id,
                createdAt: referenceDate,
                updatedAt: referenceDate,
                deletedAt: nil
            ),
            LedgerTransaction(
                id: UUID(),
                bookId: book.id,
                type: .expense,
                amountMinor: 89_00,
                currencyCode: "CNY",
                categoryLevel1Id: MockSeedData.expenseFoodCategoryId,
                categoryLevel2Id: MockSeedData.expenseCoffeeCategoryId,
                occurredAt: referenceDate.addingTimeInterval(-86_400),
                note: "午餐",
                createdBy: owner.id,
                createdAt: referenceDate,
                updatedAt: referenceDate,
                deletedAt: nil
            ),
            LedgerTransaction(
                id: UUID(),
                bookId: book.id,
                type: .expense,
                amountMinor: 32_00,
                currencyCode: "CNY",
                categoryLevel1Id: MockSeedData.expenseFoodCategoryId,
                categoryLevel2Id: MockSeedData.expenseCoffeeCategoryId,
                occurredAt: referenceDate,
                note: "咖啡",
                createdBy: MockSeedData.editorUserId,
                createdAt: referenceDate,
                updatedAt: referenceDate,
                deletedAt: nil
            )
        ]
        transactions = Dictionary(uniqueKeysWithValues: seededTransactions.map { ($0.id, $0) })
        invites = [:]
    }

    var now: Date {
        Date()
    }

    func currentUser() -> User? {
        currentUserId.flatMap { users[$0] }
    }

    func user(matching account: String) -> User? {
        let trimmed = account.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return users.values.first { user in
            user.email?.lowercased() == trimmed || user.phone == trimmed
        }
    }

    func user(id: UUID) -> User? {
        users[id]
    }

    func book(id: UUID) -> Book? {
        books[id]
    }

    func member(bookId: UUID, userId: UUID) -> BookMember? {
        members.values.first { $0.bookId == bookId && $0.userId == userId }
    }

    func member(bookId: UUID, memberOrUserId: UUID) -> BookMember? {
        members[memberOrUserId] ?? members.values.first { $0.bookId == bookId && $0.userId == memberOrUserId }
    }

    func role(bookId: UUID, userId: UUID) -> BookMemberRole? {
        member(bookId: bookId, userId: userId)?.role
    }
}
