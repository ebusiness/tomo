//
//  PostRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/15.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

// MARK: - post
extension Router {
    
    enum Post: APIRoute {
        case FindById(id: String)
        case Find(parameters: FindParameters)

        case Create(parameters: CreateParameters)
        case Delete(id: String)
        
        case Comment(id: String, content: String)
        case Bookmark(id: String)
        case Like(id: String)
        
        var path: String {
            switch self {
            case FindById(let id): return "/posts/\(id)"
            case Find: return "/posts"
            case Create: return "/posts"
            case Delete(let id): return "/posts/\(id)"
            case Comment(let id): return "/posts/\(id)/comments"
            case Bookmark(let id): return "/posts/\(id)/bookmark"
            case Like(let id): return "/posts/\(id)/like"
            }
        }
        
        var method: RouteMethod {
            switch self {
            case Create: return .POST
            case Delete: return .DELETE
            case Comment: return .POST
            case Bookmark: return .PATCH
            case Like: return .PATCH
            default: return .GET
            }
        }
        
        var parameters: [String : AnyObject]? {
            switch self {
            case Find(let parameters): return parameters.getParameters()
            case Create(let parameters): return parameters.getParameters()
            case Comment(_, let content): return ["content": content]
            default: return nil
            }
        }
    }
}

extension Router.Post {
    
    enum Category: String  {
        case all, bookmark, mine
    }
    
    struct FindParameters {
        var category: Category
        var before: NSTimeInterval?
        var after: NSTimeInterval?
        init(category: Category) {
            
            self.category = category
        }
        
        func getParameters() -> [String: AnyObject] {
            var parameters = [String: AnyObject]()
            
            parameters["category"] = category.rawValue
            if let before = before {
                parameters["before"] = String(before)
            }
            if let after = after {
                parameters["after"] = String(after)
            }
            
            return parameters
        }
    }
    
    struct CreateParameters {
        var content: String
        var images: [String]?, group: String?, coordinate: [String]?, location: String?
        init(content: String) {
            
            self.content = content
        }
        
        func getParameters() -> [String: AnyObject] {
            var parameters = [String: AnyObject]()
            
            parameters["content"] = content
            parameters["images"] = images
            parameters["group"] = group
            parameters["coordinate"] = coordinate
            parameters["location"] = location
            
            return parameters
        }
    }
}
