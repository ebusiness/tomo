//
//  UserRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/18.
//  Copyright © 2015 e-business. All rights reserved.
//


extension Router {

    enum User: APIRoute {
        case findByNickName(nickName: String?)
        case findById(id: String)
        case posts(id: String, before: TimeInterval?)
        case block(id: String)
        case map

        var path: String {
            switch self {
            case .findByNickName: return "/users"
            case let .findById(id): return "/users/\(id)"
            case let .posts(id, _): return "/users/\(id)/posts"
            case .block: return "/blocks"
            case .map: return "/map/users"
            }
        }

        var method: RouteMethod {
            switch self {
            case .block: return .POST
            default: return .GET
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case let .findByNickName(nickName):
                guard let nickName = nickName else { return nil }
                return ["nickName": nickName]
            case let .posts(_, before):
                guard let before = before else { return nil }
                return ["before": String(before)]
            case let .block(id):
                return ["id": id]
            default:
                return nil
            }
        }
    }
}
