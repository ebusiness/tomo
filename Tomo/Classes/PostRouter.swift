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
        case FindById(id: String)
        case Find(parameters: FindParameters)

        case Create(parameters: CreateParameters)
        case Delete(id: String)

        case Comment(id: String, content: String)
        case Bookmark(id: String)
        case Like(id: String)

        var path: String {
            switch self {
            case let .FindById(id): return "/posts/\(id)"
            case .Find: return "/posts"
            case .Create: return "/posts"
            case let .Delete(id): return "/posts/\(id)"
            case let .Comment(id, _): return "/posts/\(id)/comments"
            case let .Bookmark(id): return "/posts/\(id)/bookmark"
            case let .Like(id): return "/posts/\(id)/like"
            }
        }

        var method: RouteMethod {
            switch self {
            case .Create: return .POST
            case .Delete: return .DELETE
            case .Comment: return .POST
            case .Bookmark: return .PATCH
            case .Like: return .PATCH
            default: return .GET
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case let .Find(parameters): return parameters.getParameters()
            case let .Create(parameters): return parameters.getParameters()
            case let .Comment(_, content): return ["content": content]
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
