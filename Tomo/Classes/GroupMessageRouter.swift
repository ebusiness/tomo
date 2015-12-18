//
//  GroupMessageRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/18.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

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
