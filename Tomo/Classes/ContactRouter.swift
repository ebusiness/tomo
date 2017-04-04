//
//  ContactRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/18.
//  Copyright © 2015 e-business. All rights reserved.
//

extension Router {

    enum Contact: APIRoute {
        case delete(id: String)
        case all

        var path: String {
            switch self {
            case let .delete(id):
                return "/friends/\(id)"
            case .all:
                return "/friends"
//                return "/contacts"
            }
        }
        var method: RouteMethod {
            switch self {
            case .delete:
                return .DELETE
            default:
                return .GET
            }
        }
    }
}
