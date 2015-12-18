//
//  ContactRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/18.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

extension Router {
    
    struct Contact {
        
        struct Delete: APIRoute {
            let path: String
            let method = RouteMethod.DELETE
            init(id: String){
                self.path = "/friends/\(id)"
            }
        }
        
        struct List: APIRoute {
            let path = "/friends"
        }
    }
}
