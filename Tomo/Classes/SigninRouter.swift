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
        case email(email: String, password: String)
        case weChat(openid: String, access_token: String)
        case test(id: String)

        var path: String {
            switch self {
            case .email: return "/signin"
            case .weChat: return "/signin-wechat"
            case .test: return "/signin-test"
            }
        }
        var method: RouteMethod {
            switch self {
            case .email: return .POST
            case .weChat: return .POST
            case .test: return .GET
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case let .email(email, password):
                return ["email": email, "password": password]
            case let .weChat(openid, access_token):
                return ["openid": openid, "access_token": access_token, "type": "wechat"]
            case let .test(id):
                return ["id": id]
            }
        }
    }
}
