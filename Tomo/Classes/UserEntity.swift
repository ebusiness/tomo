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
    
    override init() {
        super.init()
    }
    
    required convenience init(_ respunse: AnyObject) {
        self.init(JSON(respunse))
    }
    
    required init(_ json: JSON) {
        super.init()
        self.id = json["_id"].stringValue
        self.tomoid = json["tomoid"].string
        self.nickName = json["nickName"].stringValue
        self.gender = json["gender"].string
        self.photo = json["photo_ref"].string ?? json["photo"].string
        self.cover = json["cover_ref"].string ?? json["cover"].string
        self.bio = json["bioText"].string ?? json["bio"].string 
        self.firstName = json["firstName"].string
        self.lastName = json["lastName"].string
        
        if let birthDay = json["birthDay"].string {
            self.birthDay = birthDay.toDate(format: "yyyy-MM-dd't'HH:mm:ss.SSSZ")
        }
        self.telNo = json["telNo"].string
        self.address = json["address"].string
        self.friends = json["friends"].arrayObject as? [String]
        self.invited = json["invited"].arrayObject as? [String]
        self.bookmark = json["firstName"].arrayObject as? [String]
        
        if let invitations = json["friendInvitations"].array {
            self.friendInvitations = []
            invitations.map { (invitation) -> () in
                self.friendInvitations!.append( NotificationEntity(invitation.object) )
            }
        }
        
        if let messages = json["newMessages"].array {
            self.newMessages = []
            messages.map { (message) -> () in
                self.newMessages!.append( MessageEntity(message.object) )
            }
        }
        
        if !( json["lastMessage"].object is NSNull ) {
            self.lastMessage = MessageEntity(json["lastMessage"].object)
        }
    }
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