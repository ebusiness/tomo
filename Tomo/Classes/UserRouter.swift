//
//  UserRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/18.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


extension Router {
    
    struct User {
        
        class Finder: NSObject, APIRoute {
            let path = "/users"
            
            let nickName: String
            init(nickName: String) {
                self.nickName = nickName
            }
        }
        
        struct Profile: APIRoute {
            let path: String
            init(id: String){
                self.path = "/users/\(id)"
            }
        }
        
        class Posts: NSObject, APIRoute {
            let path: String
            
            var before: String?
            
            init(id: String){
                self.path = "/users/\(id)/posts"
            }
            
        }
        
        struct Block: APIRoute {
            let path = "/blocks"
            let method = RouteMethod.POST
            let id: String
            init(id: String){
                self.id = id
            }
        }
    }
}

