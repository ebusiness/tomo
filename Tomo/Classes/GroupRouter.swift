//
//  GroupRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/15.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

// MARK: - Group
extension Router {

    enum Group: APIRoute {
        
        case FindById(id: String)
        case Find(parameters: FindParameters)
        case FindPosts(id: String, before: NSTimeInterval?)
        
        case Create(parameters: CreateParameters)
        
        case Join(id: String)
        case Leave(id: String)
        
        var path: String {
            switch self {
            case let FindById(id):
                return "/groups/\(id)"
            case let Join(id):
                return "/groups/\(id)/join"
            case let Leave(id):
                return "/groups/\(id)/leave"
            case let FindPosts(id, _):
                return "/groups/\(id)/posts"
            default:
                return "/groups"
            }
        }
        var method: RouteMethod {
            switch self {
            case Create:
                return .POST
            case Join:
                return .PATCH
            case Leave:
                return .PATCH
            default:
                return .GET
            }
        }
        var parameters: [String: AnyObject]? {
            switch self {
            case let Find(parameters):
                return parameters.getParameters()
            case let Create(parameters):
                return parameters.getParameters()
            case let FindPosts(_, before):
                if let before = before {
                    return ["before": String(before)]
                }
            default:
                return nil
            }
            return nil
        }
    }
}

extension Router.Group {
    enum Category: String  {
        case mine, discover, all
    }
    
    enum Type: String  {
        case station
    }
    
    struct FindParameters {
        var category: Category , page: Int?
        var type: Type?, name: String?, after: NSTimeInterval?, coordinate: [Double]?, hasMembers: Bool?
        
        init(category: Category) {
            self.category = category
        }
        
        func getParameters() -> [String: AnyObject] {
            var parameters = [String: AnyObject]()
            
            parameters["category"] = category.rawValue
            parameters["page"] = page ?? 0
            parameters["type"] = type?.rawValue
            parameters["name"] = name
            if let after = after {
                parameters["after"] = String(after)
            }
            parameters["coordinate"] = coordinate
            parameters["hasMembers"] = hasMembers
            
            return parameters
        }
    }
    
    struct CreateParameters {
        var name: String
        var introduction: String?, address: String?, cover: String?, members: [String]?
        
        init(name: String) {
            self.name = name
        }
        
        func getParameters() -> [String: AnyObject] {
            var parameters = [String: AnyObject]()
            
            parameters["name"] = name
            parameters["introduction"] = introduction
            parameters["address"] = address
            parameters["cover"] = cover
            parameters["members"] = members
            
            return parameters
        }
    }
}


