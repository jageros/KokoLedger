import XCTest
@testable import KouKouLedger

@MainActor
final class BookViewModelTests: XCTestCase {
    func testCreateBookSelectsNewBook() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let viewModel = BookViewModel(session: session)

        await viewModel.createBook(name: "旅行账本", note: "五月", defaultCurrencyCode: "CNY")

        XCTAssertEqual(session.currentBook?.name, "旅行账本")
        XCTAssertTrue(viewModel.books.contains { $0.name == "旅行账本" })
    }

    func testSwitchBookUpdatesSession() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let viewModel = BookViewModel(session: session)
        await viewModel.createBook(name: "家庭账本", note: nil, defaultCurrencyCode: "CNY")
        let firstBook = viewModel.books.first { $0.id == MockSeedData.primaryBookId }

        if let firstBook {
            await viewModel.switchBook(firstBook)
        }

        XCTAssertEqual(session.currentBook?.id, MockSeedData.primaryBookId)
    }

    func testNonOwnerCannotEditBook() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.editorEmail, password: MockSeedData.defaultPassword)
        let viewModel = BookViewModel(session: session)
        await viewModel.loadBooks()

        await viewModel.editBook(
            session.currentBook,
            name: "越权修改",
            note: nil,
            defaultCurrencyCode: "CNY"
        )

        XCTAssertNotNil(viewModel.alertMessage)
        XCTAssertNotEqual(session.currentBook?.name, "越权修改")
    }

    func testOwnerCanEditBook() async {
        let session = AppSession(dependencies: AppDependencyContainer(referenceDate: ServiceTestSupport.referenceDate))
        try? await session.login(account: MockSeedData.defaultEmail, password: MockSeedData.defaultPassword)
        let viewModel = BookViewModel(session: session)
        await viewModel.loadBooks()

        await viewModel.editBook(
            session.currentBook,
            name: "更新后的账本",
            note: "新备注",
            defaultCurrencyCode: "CNY"
        )

        XCTAssertNil(viewModel.alertMessage)
        XCTAssertEqual(session.currentBook?.name, "更新后的账本")
    }
}
