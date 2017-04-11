//
//  SignupRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/15.
//  Copyright © 2015 e-business. All rights reserved.
//

extension Router {
    enum Signup: APIRoute {
        case email(email: String, password: String, nickName: String)

        var path: String {
            switch self {
            case .email: return "/signup"
            }
        }

        var method: RouteMethod {
            return .POST
        }

        var parameters: [String: Any]? {

            switch self {
            case let .email(email, password, nickName):
                return ["email": email, "password": password, "nickName": nickName]
            }
        }
    }
}
