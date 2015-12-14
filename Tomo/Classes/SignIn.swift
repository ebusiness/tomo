//
//  SignIn.swift
//  Tomo
//
//  Created by starboychina on 2015/12/14.
//  Copyright © 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Alamofire

struct Router {
    class SignIn: NSObject, APIRoute {
        var path = "/signin"
        var method = Method.POST
        
        var email: String, password: String
        
        init(email: String, password: String){
            self.email = email
            self.password = password
        }
    }
    
    class SignInTest: NSObject, APIRoute {
        var path = "/signin-test"
        
        var id: String
        
        init(id: String){
            self.id = id
        }
    }
}
