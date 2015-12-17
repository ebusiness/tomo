//
//  PostRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/15.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

// MARK: - post
extension Router {
    
    struct Post {
        
        enum Category: String  {
            case all, bookmark
        }
        
        class Finder: NSObject, APIRoute {
            let path = "/posts"
            
            let category: String
            var before: String?
            var after: String?
            
            init(category: Category) {
                
                self.category = category.rawValue
            }
        }
        
        class Creater: NSObject, APIRoute {
            let path = "/posts"
            let method = RouteMethod.POST
            
            let content: String
            var images: [String]?, group: String?, coordinate: [String]?, location: String?
            
            init(content: String) {
                
                self.content = content
            }
        }
        
        struct Bookmark: APIRoute {
            let path: String
            let method = RouteMethod.PATCH
            
            init(id: String) {
                self.path = "/posts/\(id)/bookmark"
            }
        }
        
        struct Like: APIRoute {
            let path: String
            let method = RouteMethod.PATCH
            
            init(id: String) {
                self.path = "/posts/\(id)/like"
            }
        }
    }
}
