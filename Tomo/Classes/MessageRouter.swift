//
//  MessageRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/17.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

extension Router {
    
    enum Message: APIRoute {
        case FindByUserId(id: String, before: NSTimeInterval?)
        case SendTo(id: String, type: MessageType, content: String)
        
        var path: String {
            switch self {
            case let FindByUserId(id, _):
                return "/messages/\(id)"
            case SendTo:
                return "/messages"
            }
        }
        
        var method: RouteMethod {
            switch self {
            case FindByUserId: return .GET
            case SendTo: return .POST
            }
        }
        
        var parameters: [String : AnyObject]? {
            switch self {
            case let FindByUserId(_, before):
                guard let before = before else { return nil }
                return ["before": String(before)]
            case let SendTo(id, type, content): return ["to": id, "type": type.rawValue, "content": content]
            }
        }
    }
}
