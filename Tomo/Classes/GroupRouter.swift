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

        case FindById(id: String)
        case Find(parameters: FindParameters)
        case FindPosts(id: String, before: TimeInterval?)

        case Create(parameters: CreateParameters)

        case Join(id: String)
        case Leave(id: String)

        case Map(parameters: MapParameters)

        var path: String {
            switch self {
            case let .FindById(id):
                return "/groups/\(id)"
            case let .Join(id):
                return "/groups/\(id)/join"
            case let .Leave(id):
                return "/groups/\(id)/leave"
            case let .FindPosts(id, _):
                return "/groups/\(id)/posts"
            case .Map:
                return "/map/groups"
            default:
                return "/groups"
            }
        }
        var method: RouteMethod {
            switch self {
            case .Create:
                return .POST
            case .Join:
                return .PATCH
            case .Leave:
                return .PATCH
            default:
                return .GET
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case let .Find(parameters):
                return parameters.getParameters()
            case let .Create(parameters):
                return parameters.getParameters()
            case let .FindPosts(_, before):
                if let before = before {
                    return ["before": String(before)]
                }
            case let .Map(parameters):
                return parameters.getParameters()
            default:
                return nil
            }
            return nil
        }
    }
}

extension Router.Group {
    enum Category: String  {
        case mine, discover, all
    }

    enum `Type`: String  {
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
