//
//  GroupMessageRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/18.
//  Copyright © 2015 e-business. All rights reserved.
//

// MARK: - Group Messages
extension Router {

    enum GroupMessage: APIRoute {

        case findByGroupId(id: String, before: TimeInterval?)
        case sendByGroupId(id: String, type: MessageType, content: String)

        var path: String {
            switch self {
            case let .findByGroupId(id, _):
                return "/groups/\(id)/messages"
            case let .sendByGroupId(id, _, _):
                return "/groups/\(id)/messages"
            }
        }
        var method: RouteMethod {
            switch self {
            case .sendByGroupId:
                return .POST
            default:
                return .GET
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case let .findByGroupId(_, before):
                if let before = before {
                    return ["before": String(before) as Any]
                }
            case let .sendByGroupId(_, type, content):
                return ["type": type.rawValue as Any, "content": content as Any]
            }
            return nil
        }
    }

}
