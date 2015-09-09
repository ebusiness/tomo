//
//  UserEntity.swift
//  Tomo
//
//  Created by ebuser on 2015/07/30.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class UserEntity: Entity {
    
    var id: String!
    
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
    
    var invitations: [String]?
    
    var bookmark: [String]?
    
    var friendInvitations: [NotificationEntity]!
    
    var newMessages: [MessageEntity]!
    
    var lastMessage: MessageEntity?
    
    override init() {
        super.init()
    }
    
    required init(_ json: JSON) {
        super.init()
        self.id = json["id"].stringValue
        self.nickName = json["nickName"].stringValue
        self.gender = json["gender"].string
        self.photo = json["photo_ref"].string ?? json["photo"].string
        self.cover = json["cover_ref"].string ?? json["cover"].string
        self.bio = json["bio"].string ?? json["bio"].string
        self.firstName = json["firstName"].string
        self.lastName = json["lastName"].string
        
        if let birthDay = json["birthDay"].string {
            self.birthDay = birthDay.toDate(format: kDateFormat)
        }
        self.telNo = json["telNo"].string
        self.address = json["address"].string
        self.friends = json["friends"].arrayObject as? [String]
        self.invitations = json["invitations"].arrayObject as? [String]
        self.bookmark = json["firstName"].arrayObject as? [String]
        
        self.friendInvitations = []
        if let invitations = json["friendInvitations"].array {
            invitations.map { (invitation) -> () in
                self.friendInvitations.append( NotificationEntity(invitation) )
            }
        }
        
        self.newMessages = []
        if let messages = json["newMessages"].array {
            messages.map { (message) -> () in
                self.newMessages.append( MessageEntity(message) )
            }
        }
        
        if !( json["lastMessage"].object is NSNull ) {
            self.lastMessage = MessageEntity(json["lastMessage"])
        }
    }
}

extension UserEntity {
    
    func fullName() -> String {
        let fName = firstName ?? ""
        let lName = lastName ?? ""
        return "\(fName) \(lName)"
    }
    
    func addFriend(uid: String) -> Bool{
        
        self.invitations?.remove(uid)
        if let friends = self.friends where friends.contains(uid) {
            return false
        } else {
            self.friends = self.friends ?? []
            self.friends?.append(uid)
            return true
        }
    }
    
    func removeFriend(uid: String){
        
        self.invitations?.remove(uid)
        self.friends?.remove(uid)
    }
    
    func getNotificationCount() -> Int {        
        return me.friendInvitations.count + me.newMessages.count
    }
}