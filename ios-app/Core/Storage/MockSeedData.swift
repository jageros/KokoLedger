import Foundation

enum MockSeedData {
    static let defaultUserId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let editorUserId = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let readonlyUserId = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!

    static let primaryBookId = UUID(uuidString: "00000000-0000-0000-0000-000000000101")!
    static let ownerMemberId = UUID(uuidString: "00000000-0000-0000-0000-000000000201")!
    static let editorMemberId = UUID(uuidString: "00000000-0000-0000-0000-000000000202")!
    static let readonlyMemberId = UUID(uuidString: "00000000-0000-0000-0000-000000000203")!

    static let expenseFoodCategoryId = UUID(uuidString: "00000000-0000-0000-0000-000000000301")!
    static let expenseCoffeeCategoryId = UUID(uuidString: "00000000-0000-0000-0000-000000000302")!
    static let incomeSalaryCategoryId = UUID(uuidString: "00000000-0000-0000-0000-000000000303")!
    static let incomeBonusCategoryId = UUID(uuidString: "00000000-0000-0000-0000-000000000304")!

    static let defaultEmail = "owner@koukou.local"
    static let editorEmail = "editor@koukou.local"
    static let readonlyEmail = "readonly@koukou.local"
    static let defaultPhone = "13800000001"
    static let editorPhone = "13800000002"
    static let readonlyPhone = "13800000003"
    static let defaultPassword = "password123"
}
