//
//  MessageRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/17.
//  Copyright © 2015 e-business. All rights reserved.
//

extension Router {

    enum Message: APIRoute {
        case Latest
        case FindByUserId(id: String, before: TimeInterval?)
        case SendTo(id: String, type: MessageType, content: String)

        var path: String {
            switch self {
            case .Latest:
                return "/messages"
            case let .FindByUserId(id, _):
                return "/messages/\(id)"
            case .SendTo:
                return "/messages"
            }
        }

        var method: RouteMethod {
            switch self {
            case .Latest: return .GET
            case .FindByUserId: return .GET
            case .SendTo: return .POST
            }
        }

        var parameters: [String : Any]? {
            switch self {
            case .Latest:
                return nil
            case let .FindByUserId(_, before):
                guard let before = before else { return nil }
                return ["before": String(before)]
            case let .SendTo(id, type, content): return ["to": id, "type": type.rawValue, "content": content]
            }
        }
    }
}
