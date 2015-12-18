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
            case all, bookmark, mine
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
        
        struct Delete: APIRoute {
            let path: String
            let method = RouteMethod.DELETE
            
            init(id: String) {
                self.path = "/posts/\(id)"
            }
            
        }
        
        struct Detail: APIRoute {
            let path: String
            
            init(id: String) {
                self.path = "/posts/\(id)"
            }
        }
        
        class Comment: NSObject, APIRoute {
            let path: String
            let method = RouteMethod.POST
            
            let content: String
//            var replyTo: String?
            
            init(id: String, content: String) {
                self.path = "/posts/\(id)/comments"
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
