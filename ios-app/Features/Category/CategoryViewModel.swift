import Foundation
import Combine

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published private(set) var categories: [TransactionCategory] = []
    @Published var selectedType: TransactionType = .expense
    @Published var includeArchived = false
    @Published private(set) var isLoading = false
    @Published var alertMessage: String?

    private let session: AppSession
    private let repository: CategoryRepository

    init(session: AppSession) {
        self.session = session
        repository = session.dependencies.categoryRepository
    }

    var canManageCategories: Bool {
        guard let userId = session.currentUser?.id, let book = session.currentBook else {
            return false
        }
        return PermissionGuard.canManageCategories(userId: userId, book: book, memberRole: session.currentRole)
    }

    func loadCategories(includeArchived override: Bool? = nil) async {
        if let override {
            includeArchived = override
        }
        guard let userId = session.currentUser?.id, let book = session.currentBook else {
            categories = []
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            categories = try await repository.fetchCategories(
                bookId: book.id,
                type: selectedType,
                includeArchived: includeArchived,
                requestedBy: userId
            )
        } catch {
            alertMessage = message(for: error)
        }
    }

    func createLevel1Category(name: String, icon: String?, colorHex: String?, type: TransactionType) async {
        guard let userId = session.currentUser?.id, let book = session.currentBook else {
            alertMessage = "请选择账本"
            return
        }
        do {
            _ = try await repository.createLevel1Category(
                bookId: book.id,
                name: name,
                type: type,
                icon: icon,
                colorHex: colorHex,
                requestedBy: userId
            )
            selectedType = type
            await loadCategories()
        } catch {
            alertMessage = message(for: error)
        }
    }

    func createLevel2Category(parent: TransactionCategory, name: String, icon: String?, colorHex: String?) async {
        guard let userId = session.currentUser?.id, let book = session.currentBook else {
            alertMessage = "请选择账本"
            return
        }
        do {
            _ = try await repository.createLevel2Category(
                bookId: book.id,
                parentId: parent.id,
                name: name,
                icon: icon,
                colorHex: colorHex,
                requestedBy: userId
            )
            selectedType = parent.type
            await loadCategories()
        } catch {
            alertMessage = message(for: error)
        }
    }

    func updateCategory(_ category: TransactionCategory) async {
        guard let userId = session.currentUser?.id else {
            alertMessage = "请先登录"
            return
        }
        do {
            _ = try await repository.updateCategory(category, requestedBy: userId)
            selectedType = category.type
            await loadCategories()
        } catch {
            alertMessage = message(for: error)
        }
    }

    func archiveCategory(_ category: TransactionCategory) async {
        guard let userId = session.currentUser?.id, let book = session.currentBook else {
            alertMessage = "请选择账本"
            return
        }
        do {
            try await repository.archiveCategory(categoryId: category.id, bookId: book.id, requestedBy: userId)
            await loadCategories(includeArchived: true)
        } catch {
            alertMessage = message(for: error)
        }
    }

    func children(of parent: TransactionCategory) -> [TransactionCategory] {
        categories.filter { $0.parentId == parent.id }
    }

    var primaryCategories: [TransactionCategory] {
        categories.filter { $0.level == .level1 }
    }

    private func message(for error: Error) -> String {
        switch error as? AppError {
        case .permission:
            return "当前权限不能管理分类"
        case .validation:
            return "请检查分类信息"
        default:
            return "分类操作失败"
        }
    }
}
