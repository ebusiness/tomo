//
//  SignupRouter.swift
//  Tomo
//
//  Created by starboychina on 2015/12/15.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

extension Router {
    struct Signup {
        class Email: NSObject, APIRoute {
            let path = "/signup"
            let method = RouteMethod.POST
            
            let email: String, password: String, nickName: String
            
            init(email: String, password: String, nickName: String) {
                self.nickName = nickName
                self.email = email
                self.password = password
            }
        }
        
        class WeChat: NSObject, APIRoute {
            let path = "/signup-wechat"
            let method = RouteMethod.POST
            
            let openid: String, nickname: String
            
            var sex: String? = "男", headimgurl: String?
            
            init(openid: String, nickname: String) {
                self.openid = openid
                self.nickname = nickname
            }
        }
    }
}
