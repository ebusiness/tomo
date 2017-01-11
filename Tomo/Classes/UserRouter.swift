//
//  UserRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/18.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


extension Router {
    
    enum User: APIRoute {
        case FindByNickName(nickName: String?)
        case FindById(id: String)
        case Posts(id: String, before: TimeInterval?)
        case Block(id: String)
        case Map
        
        var path: String {
            switch self {
            case .FindByNickName: return "/users"
            case let .FindById(id): return "/users/\(id)"
            case let .Posts(id, _): return "/users/\(id)/posts"
            case .Block: return "/blocks"
            case .Map: return "/map/users"
            }
        }
        
        var method: RouteMethod {
            switch self {
            case .Block: return .POST
            default: return .GET
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case let .FindByNickName(nickName):
                guard let nickName = nickName else { return nil }
                return ["nickName": nickName]
            case let .Posts(_, before):
                guard let before = before else { return nil }
                return ["before": String(before)]
            case let .Block(id):
                return ["id": id]
            default:
                return nil
            }
        }
    }
}

