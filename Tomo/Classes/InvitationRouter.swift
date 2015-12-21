//
//  InvitationRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/15.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

// MARK: - Connection
extension Router {
    
    enum Invitation: APIRoute {
        
        case Find
        case ModifyById(id: String, accepted: Bool)
        case SendTo(id: String)
        
        var path: String {
            switch self {
            case ModifyById(let id):
                return "/invitations/\(id)"
            default:
                return "/invitations"
            }
        }
        var method: RouteMethod {
            switch self {
            case Find: return .GET
            case ModifyById: return .PATCH
            case SendTo: return .POST
            }
        }
        
        var parameters: [String : AnyObject]? {
            switch self {
            case Find: return nil
            case ModifyById(_, let accepted): return ["result": accepted ? "accept" : "refuse"]
            case SendTo(let id): return ["id": id]
            }
        }
    }
    
}
