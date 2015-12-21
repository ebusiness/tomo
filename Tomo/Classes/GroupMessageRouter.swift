//
//  GroupMessageRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/18.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

// MARK: - Group Messages
extension Router {
    
    enum GroupMessage: APIRoute {
        case FindByGroupId(id: String, before: NSTimeInterval?)
        case SendByGroupId(id: String, content: String)
        
        var path: String {
            switch self {
            case FindByGroupId(let id):
                return "/groups/\(id)/messages"
            case SendByGroupId(let id):
                return "/groups/\(id)/messages"
            }
        }
        var method: RouteMethod {
            switch self {
            case SendByGroupId:
                return .POST
            default:
                return .GET
            }
        }
        var parameters: [String: AnyObject]? {
            switch self {
            case FindByGroupId(_, let before):
                if let before = before {
                    return ["before": String(before)]
                }
            case SendByGroupId(_, let content):
                return ["content": content]
            }
            return nil
        }
    }
    
    
}
