//
//  InvitationRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/15.
//  Copyright © 2015 e-business. All rights reserved.
//

// MARK: - Connection
extension Router {

    enum Invitation: APIRoute {

        case find
        case modifyById(id: String, accepted: Bool)
        case sendTo(id: String)

        var path: String {
            switch self {
            case let .modifyById(id, _):
                return "/invitations/\(id)"
            default:
                return "/invitations"
            }
        }
        var method: RouteMethod {
            switch self {
            case .find: return .GET
            case .modifyById: return .PATCH
            case .sendTo: return .POST
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .find: return nil
            case let .modifyById(_, accepted): return ["result": accepted ? "accept" : "refuse"]
            case let .sendTo(id): return ["id": id]
            }
        }
    }

}
