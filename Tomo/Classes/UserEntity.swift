//
//  UserEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/07/30.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class UserEntity: NSObject {
    
    var id: String!
    
    var tomoid: String!
    
    var nickName: String!
    
    var gender: String?
    
    var photo: String?
    
    var cover: String?
    
    var bio: String?
    
    var firstName: String?
    
    var lastName: String?
    
    var birthDay: NSDate?
    
    var telNo: String?
    
    var address: String?
    
    var friends: [String]?
    
    var invited: [String]?
}

extension UserEntity {
    
    func fullName() -> String {
        let fName = firstName ?? ""
        let lName = lastName ?? ""
        return "\(fName) \(lName)"
    }
}