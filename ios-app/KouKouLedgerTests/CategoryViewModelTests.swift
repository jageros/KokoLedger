import XCTest
@testable import KouKouLedger

@MainActor
final class CategoryViewModelTests: XCTestCase {
    func testOwnerCanCreateCategory() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let viewModel = CategoryViewModel(session: session)

        await viewModel.createLevel1Category(name: "娱乐", icon: "sparkles", colorHex: "#FF9500", type: .expense)

        XCTAssertTrue(viewModel.categories.contains { $0.name == "娱乐" })
    }

    func testEditorCanCreateCategory() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.editorEmail, password: MockSeedData.defaultPassword)
        let viewModel = CategoryViewModel(session: session)

        await viewModel.createLevel1Category(name: "兼职", icon: "briefcase", colorHex: "#34C759", type: .income)

        XCTAssertTrue(viewModel.categories.contains { $0.name == "兼职" })
    }

    func testReadonlyCannotCreateCategory() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.readonlyEmail, password: MockSeedData.defaultPassword)
        let viewModel = CategoryViewModel(session: session)

        await viewModel.createLevel1Category(name: "只读新增", icon: nil, colorHex: nil, type: .expense)

        XCTAssertFalse(viewModel.categories.contains { $0.name == "只读新增" })
        XCTAssertNotNil(viewModel.alertMessage)
    }

    func testLevel2CategoryBindsParentType() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let viewModel = CategoryViewModel(session: session)
        await viewModel.loadCategories()
        let parent = viewModel.categories.first { $0.level == .level1 && $0.type == .expense }

        if let parent {
            await viewModel.createLevel2Category(parent: parent, name: "夜宵", icon: "moon", colorHex: "#AF52DE")
        }

        let child = viewModel.categories.first { $0.name == "夜宵" }
        XCTAssertEqual(child?.parentId, parent?.id)
        XCTAssertEqual(child?.type, parent?.type)
    }

    func testArchiveCategorySucceeds() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let viewModel = CategoryViewModel(session: session)
        await viewModel.loadCategories(includeArchived: true)
        let category = viewModel.categories.first { !$0.isArchived }

        if let category {
            await viewModel.archiveCategory(category)
        }

        XCTAssertTrue(viewModel.categories.first { $0.id == category?.id }?.isArchived == true)
    }
}
