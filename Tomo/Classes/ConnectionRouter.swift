//
//  ConnectionRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/15.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

// MARK: - Connection
extension Router {
    
    struct Invitations {
        struct Finder: APIRoute {
            let path = "/invitations"
        }
        
        class Updater: NSObject, APIRoute {
            var path = "/invitations/"
            let method = RouteMethod.PATCH
            
            let result: String
            
            init(id: String, accepted: Bool) {
                self.path += id
                self.result = accepted ? "accept" : "refuse"
            }
        }
    }
    
    struct Friends: APIRoute {
        let path = "/friends"
    }
    
}
