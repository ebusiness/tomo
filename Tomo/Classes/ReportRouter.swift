//
//  ReportRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/18.
//  Copyright © 2015 e-business. All rights reserved.
//

// MARK: - report
extension Router {

    enum Report: APIRoute {
        case post(id: String)
        case user(id: String)

        var path: String {
            switch self {
            case let .post(id): return "/reports/posts/\(id)"
            case let .user(id): return "/reports/users/\(id)"
            }
        }
        var method: RouteMethod {
            return .POST
        }
    }
}
