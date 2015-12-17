//
//  GroupRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/15.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

// MARK: - Group
extension Router {
    
    struct Group {
        
        enum Category: String  {
            case mine, discover, all
        }
        
        enum Type: String  {
            case station
        }
        
        class Finder: NSObject, APIRoute {
            let path = "/groups"
            
            var category: String
            
            var page: Int
            var type: Type?
            var name: String?
            var after: String?
            var coordinate: [Double]?
            var hasMembers: Bool?
            
            init(category: Category = .all, page: Int = 0) {
                self.category = category.rawValue
                self.page = page
            }
            
            func setCategory(category: Category){
                self.category = category.rawValue
            }
        }
        
        class Creater: NSObject, APIRoute {
            let path = "/groups"
            let method = RouteMethod.POST
            
            let name: String
            var introduction: String?, address: String?, cover: String?
            var members: [String]?
            
            init(name: String) {
                self.name = name
            }
        }
        
        struct Detail: APIRoute {
            let path: String
            
            init(id: String) {
                self.path = "/groups/\(id)"
            }
        }
        
        struct Join: APIRoute {
            let path: String
            let method = RouteMethod.PATCH
            
            init(id: String) {
                self.path = "/groups/\(id)/join"
            }
        }
        
        struct Leave: APIRoute {
            let path: String
            let method = RouteMethod.PATCH
            
            init(id: String) {
                self.path = "/groups/\(id)/leave"
            }
        }
        
        class Posts: NSObject, APIRoute {
            let path: String
            
            var before: String?
            
            init(id: String) {
                self.path = "/groups/\(id)/posts"
            }
        }
    }
}

// MARK: - Group Messages
extension Router {
    
    struct GroupMessage {
        class Finder: NSObject, APIRoute {
            let path: String
            
            var before: String?
            
            init(id: String) {
                self.path = "/groups/\(id)/messages"
            }
        }
        
        class Creater: NSObject, APIRoute {
            let path: String
            var method = RouteMethod.POST
            
            let content: String
            
            init(id: String, content: String) {
                self.path = "/groups/\(id)/messages"
                self.content = content
            }
        }
    }
    
    
}

