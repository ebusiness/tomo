//
//  ContactRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/18.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

extension Router {

    enum Contact: APIRoute {
        case Delete(id: String)
        case All

        var path: String {
            switch self {
            case let .Delete(id):
                return "/friends/\(id)"
            case .All:
                return "/friends"
//                return "/contacts"
            }
        }
        var method: RouteMethod {
            switch self {
            case .Delete:
                return .DELETE
            default:
                return .GET
            }
        }
    }
}
