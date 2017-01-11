//
//  SignupRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/15.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

extension Router {
    enum Signup: APIRoute {
        case Email(email: String, password: String, nickName: String)
        case WeChat(openid: String, nickname: String, gender: String?, headimgurl: String?)

        var path: String {
            switch self {
            case .Email: return "/signup"
            case .WeChat: return "/signup-wechat"
            }
        }

        var method: RouteMethod {
            return .POST
        }

        var parameters: [String: Any]? {

            switch self {
            case let .Email(email, password, nickName):
                return ["email": email, "password": password, "nickName": nickName]
            case let .WeChat(openid, nickname, gender, headimgurl):
                var parameters = ["openid": openid, "nickname": nickname]

                if let gender = gender {
                    parameters["sex"] = gender == "2" ? "女" : "男"
                } else {
                    parameters["sex"] = "男"
                }

                if let headimgurl = headimgurl {
                    parameters["headimgurl"] = headimgurl
                }
                return parameters
            }
        }
    }
}
