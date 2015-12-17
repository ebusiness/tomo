//
//  SigninRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/14.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

extension Router {

    struct Session: APIRoute {
        var path = "/session"
    }
    
    struct Signin {
        class Email: NSObject, APIRoute {
            let path = "/signin"
            let method = RouteMethod.POST
            
            let email: String, password: String
            
            init(email: String, password: String) {
                self.email = email
                self.password = password
            }
        }
        
        class WeChat: NSObject, APIRoute {
            let path = "/signin-wechat"
            let method = RouteMethod.POST
            
            private let type = "wechat"
            let openid: String, access_token: String
            
            init(openid: String, access_token: String) {
                self.openid = openid
                self.access_token = access_token
            }
        }
        
        class Test: NSObject, APIRoute {
            let path = "/signin-test"
            
            let id: String
            
            init(id: String){
                self.id = id
            }
        }
    }
    
    struct Signout: APIRoute {
        let path = "/signout"
    }
}
