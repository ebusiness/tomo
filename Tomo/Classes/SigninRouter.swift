//
//  SigninRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/14.
//  Copyright © 2015 e-business. All rights reserved.
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
            switch self {
            case .Email: return "/signin"
            case .WeChat: return "/signin-wechat"
            case .Test: return "/signin-test"
            }
        }
        var method: RouteMethod {
            switch self {
            case .Email: return .POST
            case .WeChat: return .POST
            case .Test: return .GET
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case let .Email(email, password):
                return ["email": email, "password": password]
            case let .WeChat(openid, access_token):
                return ["openid": openid, "access_token": access_token, "type": "wechat"]
            case let .Test(id):
                return ["id": id]
            }
        }
    }
}
