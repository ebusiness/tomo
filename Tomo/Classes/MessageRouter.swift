//
//  MessageRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/17.
//  Copyright © 2015 e-business. All rights reserved.
//

extension Router {

    enum Message: APIRoute {
        case latest
        case findByUserId(id: String, before: TimeInterval?)
        case sendTo(id: String, type: MessageType, content: String)

        var path: String {
            switch self {
            case .latest:
                return "/messages"
            case let .findByUserId(id, _):
                return "/messages/\(id)"
            case .sendTo:
                return "/messages"
            }
        }

        var method: RouteMethod {
            switch self {
            case .latest: return .GET
            case .findByUserId: return .GET
            case .sendTo: return .POST
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .latest:
                return nil
            case let .findByUserId(_, before):
                guard let before = before else { return nil }
                return ["before": String(before)]
            case let .sendTo(id, type, content): return ["to": id, "type": type.rawValue, "content": content]
            }
        }
    }
}
