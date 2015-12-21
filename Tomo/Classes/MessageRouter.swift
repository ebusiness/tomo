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
        case SendTo(id: String, content: String)
        
        var path: String {
            switch self {
            case FindByUserId(let id):
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
            case FindByUserId(_, let before): return ["before": String(before)]
            case SendTo(let id, let content): return ["to": id, "content": content]
            }
        }
    }
}
