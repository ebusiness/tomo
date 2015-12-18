//
//  ReportRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/18.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

// MARK: - report
extension Router {
    
    struct Report {
        
        struct Post: APIRoute {
            let path: String
            let method = RouteMethod.POST
            init(id: String){
                self.path = "/reports/posts/\(id)"
            }
        }
        
        struct User: APIRoute {
            let path: String
            let method = RouteMethod.POST
            init(id: String){
                self.path = "/reports/users/\(id)"
            }
        }
    }
}
