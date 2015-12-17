//
//  MessageRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/17.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

extension Router {
    
    struct Message {
        class Finder: NSObject, APIRoute {
            let path: String
            
            var before: String?
            
            init(id: String){
                self.path = "/messages/\(id)"
            }
        }
        
        class Creater: NSObject, APIRoute {
            let path = "/messages"
            let method = RouteMethod.POST
            
            let to: String, content: String
            
            init(to: String, content: String){
                self.to = to
                self.content = content
            }
        }
    }
}
