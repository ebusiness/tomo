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
    
    var tomoid: String?
    
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
    
    var bookmark: [String]?
    
    var friendInvitations: [NotificationEntity]?
    
    var newMessages: [MessageEntity]?
    
    var lastMessage: MessageEntity?
}

extension UserEntity {
    
    func fullName() -> String {
        let fName = firstName ?? ""
        let lName = lastName ?? ""
        return "\(fName) \(lName)"
    }
    
    func addFriend(uid: String){
        
        self.invited?.remove(uid)
        if let friends = self.friends where friends.contains(uid) {

        } else {
            self.friends = self.friends ?? []
            self.friends?.append(uid)
        }
    }
    
    func removeFriend(uid: String){
        
        self.invited?.remove(uid)
        self.friends?.remove(uid)
    }
}