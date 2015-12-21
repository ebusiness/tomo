//
//  SigninRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/14.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

extension Router {

    struct Session: APIRoute {
        var path = "/session"
    }
    
    struct Signout: APIRoute {
        let path = "/signout"
    }
    
    enum Signin: APIRoute {
        case Email(email: String, password: String)
        case WeChat(openid: String, access_token: String)
        case Test(id: String)
        
        var path: String {
            switch self{
            case Email: return "/signin"
            case WeChat: return "/signin-wechat"
            case Test: return "/signin-test"
            }
        }
        var method: RouteMethod {
            switch self{
            case Email: return .POST
            case WeChat: return .POST
            case Test: return .GET
            }
        }
        var parameters: [String: AnyObject]? {
            switch self{
            case Email(let email, let password):
                return ["email": email, "password": password]
            case WeChat(let openid, let access_token):
                return ["openid": openid, "access_token": access_token, "type": "wechat"]
            case Test(let id):
                return ["id": id]
            }
        }
    }
}
