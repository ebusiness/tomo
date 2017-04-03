//
//  CompanyRoute.swift
//  Tomo
//
//  Created by starboychina on 2017/04/03.
//  Copyright © 2017  e-business. All rights reserved.
//

extension Router {

    enum Company: APIRoute {

        case findById(id: String)
        case find(parameters: Parameters)

        case create(parameters: Parameters)

        case join(id: String)
        case leave(id: String)

        var path: String {
            switch self {
            case let .findById(id):
                return "/companies/\(id)"
            case let .join(id):
                return "/companies/\(id)/join"
            case let .leave(id):
                return "/companies/\(id)/leave"
            default:
                return "/companies"
            }
        }
        var method: RouteMethod {
            switch self {
            case .create:
                return .POST
            case .join:
                return .PATCH
            case .leave:
                return .PATCH
            default:
                return .GET
            }
        }
        var parameters: [String: Any]? {
            switch self {
            case let .find(parameters):
                return parameters.getParameters()
            case let .create(parameters):
                return parameters.getParameters()
            default:
                return nil
            }
        }
    }
}

extension Router.Company {
    enum `Type`: String {
        case si, end, all
    }

    struct Parameters {
        var page: Int?, type: Type?, name: String?, after: TimeInterval?, coordinate: [Double]?, address: String?

        init(type: Type) {
            self.type = type
        }

        func getParameters() -> [String: Any] {
            var parameters = [String: Any]()

            parameters["page"] = page ?? 0
            parameters["type"] = type?.rawValue
            parameters["name"] = name
            if let after = after {
                parameters["after"] = String(after)
            }
            parameters["coordinate"] = coordinate
            parameters["address"] = address

            return parameters
        }
    }
}
