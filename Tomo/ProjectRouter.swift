//
//  ProjectRouter.swift
//  Tomo
//
//  Created by 李超逸 on 2017/4/7.
//  Copyright © 2017年  e-business. All rights reserved.
//

import Foundation

extension Router {

    enum Project: APIRoute {
        case find(parameters: FindParameters)

        var path: String {
            switch self {
            case .find(_):
                return "/projects"
            }
        }

        var method: RouteMethod {
            switch self {
            case .find(_):
                return .GET
            }
        }

        var parameters: [String : Any]? {
            switch self {
            case let .find(parameters):
                return parameters.serialize()
            }
        }

    }
}

extension Router.Project {
    struct FindParameters {
        var box: [Double]?

        init() {
        }

        func serialize() -> [String: Any] {
            var parameters = [String: Any]()

            parameters["box"] = box

            return parameters
        }
    }
}
