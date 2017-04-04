//
//  GroupRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/15.
//  Copyright © 2015 e-business. All rights reserved.
//

// MARK: - Group
extension Router {

    enum Group: APIRoute {

        case findById(id: String)
        case find(parameters: FindParameters)
        case findPosts(id: String, before: TimeInterval?)

        case create(parameters: CreateParameters)

        case join(id: String)
        case leave(id: String)

        case map(parameters: MapParameters)

        var path: String {
            switch self {
            case let .findById(id):
                return "/groups/\(id)"
            case let .join(id):
                return "/groups/\(id)/join"
            case let .leave(id):
                return "/groups/\(id)/leave"
            case let .findPosts(id, _):
                return "/groups/\(id)/posts"
            case .map:
                return "/map/groups"
            default:
                return "/groups"
            }
        }
        var method: RouteMethod {
            switch self {
            case .create:
                return .POST
            case .join:
                return .PATCH
            case .leave:
                return .PATCH
            default:
                return .GET
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case let .find(parameters):
                return parameters.getParameters()
            case let .create(parameters):
                return parameters.getParameters()
            case let .findPosts(_, before):
                if let before = before {
                    return ["before": String(before)]
                }
            case let .map(parameters):
                return parameters.getParameters()
            default:
                return nil
            }
            return nil
        }
    }
}

extension Router.Group {
    enum Category: String {
        case mine, discover, all
    }

    enum `Type`: String {
        case station
    }

    struct FindParameters {
        var category: Category , page: Int?
        var type: Type?, name: String?, after: TimeInterval?, coordinate: [Double]?, hasMembers: Bool?

        init(category: Category) {
            self.category = category
        }

        func getParameters() -> [String: Any] {
            var parameters = [String: Any]()

            parameters["category"] = category.rawValue
//            if let page = page {
//                parameters["page"] = page
//            }
            parameters["page"] = page ?? 0
            parameters["type"] = type?.rawValue
            parameters["name"] = name
            if let after = after {
                parameters["after"] = String(after)
            }
            parameters["coordinate"] = coordinate
            parameters["hasMembers"] = hasMembers

            return parameters
        }
    }

    struct MapParameters {

        var category: Category
        var type: Type?
        var name: String?
        var coordinate: [Double]?
        var hasMembers: Bool?

        init(category: Category) {
            self.category = category
        }

        func getParameters() -> [String: Any] {
            var parameters = [String: Any]()

            parameters["category"] = category.rawValue
            parameters["type"] = type?.rawValue
            parameters["name"] = name
            parameters["coordinate"] = coordinate
            parameters["hasMembers"] = hasMembers

            return parameters
        }
    }

    struct CreateParameters {
        var name: String
        var introduction: String?, address: String?, cover: String?, members: [String]?

        init(name: String) {
            self.name = name
        }

        func getParameters() -> [String: Any] {
            var parameters = [String: Any]()

            parameters["name"] = name
            parameters["introduction"] = introduction
            parameters["address"] = address
            parameters["cover"] = cover
            parameters["members"] = members

            return parameters
        }
    }
}
