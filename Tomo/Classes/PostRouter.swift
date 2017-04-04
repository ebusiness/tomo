//
//  PostRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/15.
//  Copyright © 2015 e-business. All rights reserved.
//

// MARK: - post
extension Router {

    enum Post: APIRoute {
        case findById(id: String)
        case find(parameters: FindParameters)

        case create(parameters: CreateParameters)
        case delete(id: String)

        case comment(id: String, content: String)
        case bookmark(id: String)
        case like(id: String)

        var path: String {
            switch self {
            case let .findById(id): return "/posts/\(id)"
            case .find: return "/posts"
            case .create: return "/posts"
            case let .delete(id): return "/posts/\(id)"
            case let .comment(id, _): return "/posts/\(id)/comments"
            case let .bookmark(id): return "/posts/\(id)/bookmark"
            case let .like(id): return "/posts/\(id)/like"
            }
        }

        var method: RouteMethod {
            switch self {
            case .create: return .POST
            case .delete: return .DELETE
            case .comment: return .POST
            case .bookmark: return .PATCH
            case .like: return .PATCH
            default: return .GET
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case let .find(parameters): return parameters.getParameters()
            case let .create(parameters): return parameters.getParameters()
            case let .comment(_, content): return ["content": content]
            default: return nil
            }
        }
    }
}

extension Router.Post {

    enum Category: String  {
        case all, bookmark, mine
    }

    struct FindParameters {
        var category: Category
        var before: TimeInterval?
        var after: TimeInterval?
        init(category: Category) {

            self.category = category
        }

        func getParameters() -> [String: Any] {
            var parameters = [String: Any]()

            parameters["category"] = category.rawValue
            if let before = before {
                parameters["before"] = String(before)
            }
            if let after = after {
                parameters["after"] = String(after)
            }

            return parameters
        }
    }

    struct CreateParameters {
        var content: String
        var images: [String]?, group: String?, coordinate: [String]?, location: String?
        init(content: String) {

            self.content = content
        }

        func getParameters() -> [String: Any] {
            var parameters = [String: Any]()

            parameters["content"] = content
            parameters["images"] = images
            parameters["group"] = group
            parameters["coordinate"] = coordinate
            parameters["location"] = location

            return parameters
        }
    }
}
