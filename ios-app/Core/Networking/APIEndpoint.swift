import Foundation

struct APIEndpoint: Equatable {
    enum Method: String, Equatable {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    let method: Method
    let path: String
    let queryItems: [URLQueryItem]

    init(method: Method, path: String, queryItems: [URLQueryItem] = []) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
    }
}

extension APIEndpoint {
    static let authRegister = APIEndpoint(method: .post, path: "/auth/register")
    static let authLogin = APIEndpoint(method: .post, path: "/auth/login")
    static let authLogout = APIEndpoint(method: .post, path: "/auth/logout")
    static let authMe = APIEndpoint(method: .get, path: "/auth/me")

    static let books = APIEndpoint(method: .get, path: "/books")
    static let createBook = APIEndpoint(method: .post, path: "/books")

    static func book(id bookId: UUID) -> APIEndpoint {
        APIEndpoint(method: .get, path: "/books/\(bookId.uuidString)")
    }

    static func updateBook(id bookId: UUID) -> APIEndpoint {
        APIEndpoint(method: .patch, path: "/books/\(bookId.uuidString)")
    }

    static func deleteBook(id bookId: UUID) -> APIEndpoint {
        APIEndpoint(method: .delete, path: "/books/\(bookId.uuidString)")
    }

    static func members(bookId: UUID) -> APIEndpoint {
        APIEndpoint(method: .get, path: "/books/\(bookId.uuidString)/members")
    }

    static func updateMemberRole(bookId: UUID, memberId: UUID) -> APIEndpoint {
        APIEndpoint(method: .patch, path: "/books/\(bookId.uuidString)/members/\(memberId.uuidString)/role")
    }

    static func deleteMember(bookId: UUID, memberId: UUID) -> APIEndpoint {
        APIEndpoint(method: .delete, path: "/books/\(bookId.uuidString)/members/\(memberId.uuidString)")
    }

    static func createInvite(bookId: UUID) -> APIEndpoint {
        APIEndpoint(method: .post, path: "/books/\(bookId.uuidString)/invites")
    }

    static func invites(bookId: UUID) -> APIEndpoint {
        APIEndpoint(method: .get, path: "/books/\(bookId.uuidString)/invites")
    }

    static func acceptInvite(inviteCode: String) -> APIEndpoint {
        APIEndpoint(method: .post, path: "/invites/\(inviteCode)/accept")
    }

    static func deleteInvite(bookId: UUID, inviteId: UUID) -> APIEndpoint {
        APIEndpoint(method: .delete, path: "/books/\(bookId.uuidString)/invites/\(inviteId.uuidString)")
    }

    static func categories(bookId: UUID, type: TransactionType? = nil, includeArchived: Bool = false) -> APIEndpoint {
        var queryItems: [URLQueryItem] = []
        if let type {
            queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
        }
        if includeArchived {
            queryItems.append(URLQueryItem(name: "includeArchived", value: "true"))
        }
        return APIEndpoint(method: .get, path: "/books/\(bookId.uuidString)/categories", queryItems: queryItems)
    }

    static func createCategory(bookId: UUID) -> APIEndpoint {
        APIEndpoint(method: .post, path: "/books/\(bookId.uuidString)/categories")
    }

    static func updateCategory(bookId: UUID, categoryId: UUID) -> APIEndpoint {
        APIEndpoint(method: .patch, path: "/books/\(bookId.uuidString)/categories/\(categoryId.uuidString)")
    }

    static func deleteCategory(bookId: UUID, categoryId: UUID) -> APIEndpoint {
        APIEndpoint(method: .delete, path: "/books/\(bookId.uuidString)/categories/\(categoryId.uuidString)")
    }

    static func transactions(bookId: UUID, from: String? = nil, to: String? = nil) -> APIEndpoint {
        var queryItems: [URLQueryItem] = []
        if let from {
            queryItems.append(URLQueryItem(name: "from", value: from))
        }
        if let to {
            queryItems.append(URLQueryItem(name: "to", value: to))
        }

        return APIEndpoint(
            method: .get,
            path: "/books/\(bookId.uuidString)/transactions",
            queryItems: queryItems
        )
    }

    static func createTransaction(bookId: UUID) -> APIEndpoint {
        APIEndpoint(method: .post, path: "/books/\(bookId.uuidString)/transactions")
    }

    static func updateTransaction(bookId: UUID, transactionId: UUID) -> APIEndpoint {
        APIEndpoint(method: .patch, path: "/books/\(bookId.uuidString)/transactions/\(transactionId.uuidString)")
    }

    static func transaction(bookId: UUID, transactionId: UUID) -> APIEndpoint {
        APIEndpoint(method: .get, path: "/books/\(bookId.uuidString)/transactions/\(transactionId.uuidString)")
    }

    static func deleteTransaction(bookId: UUID, transactionId: UUID) -> APIEndpoint {
        APIEndpoint(method: .delete, path: "/books/\(bookId.uuidString)/transactions/\(transactionId.uuidString)")
    }

    static func ledgerSummary(bookId: UUID) -> APIEndpoint {
        APIEndpoint(method: .get, path: "/books/\(bookId.uuidString)/summary")
    }

    static func statisticsSnapshot(bookId: UUID, scope: StatisticsTimeScope, relativeTo: String? = nil) -> APIEndpoint {
        var queryItems = [URLQueryItem(name: "scope", value: scope.rawValue)]
        if let relativeTo {
            queryItems.append(URLQueryItem(name: "relativeTo", value: relativeTo))
        }
        APIEndpoint(
            method: .get,
            path: "/books/\(bookId.uuidString)/statistics/snapshot",
            queryItems: queryItems
        )
    }

    static func statisticsTrend(bookId: UUID, scope: StatisticsTimeScope, relativeTo: String? = nil) -> APIEndpoint {
        var queryItems = [URLQueryItem(name: "scope", value: scope.rawValue)]
        if let relativeTo {
            queryItems.append(URLQueryItem(name: "relativeTo", value: relativeTo))
        }
        APIEndpoint(
            method: .get,
            path: "/books/\(bookId.uuidString)/statistics/trend",
            queryItems: queryItems
        )
    }

    static func statisticsCategories(
        bookId: UUID,
        scope: StatisticsTimeScope,
        type: TransactionType,
        level: CategoryLevel,
        relativeTo: String? = nil
    ) -> APIEndpoint {
        var queryItems = [
            URLQueryItem(name: "scope", value: scope.rawValue),
            URLQueryItem(name: "type", value: type.rawValue),
            URLQueryItem(name: "level", value: level.rawValue)
        ]
        if let relativeTo {
            queryItems.append(URLQueryItem(name: "relativeTo", value: relativeTo))
        }
        APIEndpoint(
            method: .get,
            path: "/books/\(bookId.uuidString)/statistics/categories",
            queryItems: queryItems
        )
    }
}
