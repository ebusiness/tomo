//
//  UserRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/18.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


extension Router {
    
    enum User: APIRoute {
        case FindByNickName(nickName: String)
        case FindById(id: String)
        case Posts(id: String, before: NSTimeInterval?)
        case Block(id: String)
        
        var path: String {
            switch self {
            case FindByNickName: return "/users"
            case FindById(let id): return "/users/\(id)"
            case Posts(let id): return "/users/\(id)/posts"
            case Block: return "/blocks"
            }
        }
        
        var method: RouteMethod {
            switch self {
            case Block: return .POST
            default: return .GET
            }
        }
        
        var parameters: [String : AnyObject]? {
            switch self {
            case FindByNickName(let nickName):
                return ["nickName": nickName]
            case Posts(_, let before):
                if let before = before {
                    return ["before": before]
                }
            case Block(let id):
                return ["id": id]
            default:
                return nil
            }
            return nil
        }
    }
}

