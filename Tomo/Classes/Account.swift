//
//  Me.swift
//  Tomo
//
//  Created by starboychina on 2016/01/18.
//  Copyright © 2016年 &#24373;&#24535;&#33775;. All rights reserved.
//

import SwiftyJSON
class Account: UserEntity {
    
    var telNo: String?
    
    var friends: [String]?
    
    var groups: [String]?
    
    var invitations: [String]?
    
    var blockUsers: [String]?
    
    var friendInvitations: [NotificationEntity]!
    
    var newMessages: [MessageEntity]!
    
    var notifications: Int!
    
    var pushSetting = PushSetting()
    
    override init() {
        super.init()
    }
    
    required init(_ json: JSON) {
        
        super.init(json)
        
        self.telNo = json["telNo"].string
        
        self.friends = json["friends"].arrayObject as? [String]
        
        self.groups = json["groups"].arrayObject as? [String]
        
        self.invitations = json["invitations"].arrayObject as? [String]
        
        self.blockUsers = json["blockUsers"].arrayObject as? [String]
        
        self.friendInvitations = []
        if let invitations = json["friendInvitations"].array {
            invitations.forEach { (invitation) -> () in
                self.friendInvitations.append( NotificationEntity(invitation) )
            }
        }
        
        self.newMessages = []
        if let messages = json["newMessages"].array {
            messages.forEach { (message) -> () in
                self.newMessages.append( MessageEntity(message) )
            }
        }
        
        self.notifications = json["notifications"].intValue
        
        self.pushSetting = PushSetting(json["pushSetting"])
    }

}
// MARK: - Friend
extension Account {
    func addFriend(uid: String) -> Bool{
        
        self.invitations?.remove(uid)
        self.friendInvitations = self.friendInvitations.filter { $0.from.id != uid }
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
        self.friendInvitations = self.friendInvitations.filter { $0.from.id != uid }
        self.newMessages = self.newMessages.filter { $0.from.id != uid }
        self.friends?.remove(uid)
    }
}
// MARK: - group
extension Account {
    func addGroup(groupId: String) {
        if groupId.length > 0 {
            self.groups = self.groups ?? []
            self.groups!.append(groupId)
        }
    }
}

extension Account {
    class PushSetting: Entity  {
        var announcement: Bool = true
        var message: Bool = true
        var groupMessage: Bool = true
        var friendInvited: Bool = true
        var friendAccepted: Bool = true
        var friendRefused: Bool = true
        var friendBreak: Bool = true
        var postNew: Bool = true
        var postCommented: Bool = true
        var postLiked: Bool = true
        var postBookmarked: Bool = true
        var groupJoined: Bool = true
        var groupLeft: Bool = true
        
        override init() {
            super.init()
        }
        
        required init(_ json: JSON) {
            
            super.init()
            
            self.announcement = json["announcement"].boolValue
            self.message = json["message"].boolValue
            self.groupMessage = json["groupMessage"].boolValue
            self.friendInvited = json["friendInvited"].boolValue
            self.friendAccepted = json["friendAccepted"].boolValue
            self.friendRefused = json["friendRefused"].boolValue
            self.friendBreak = json["friendBreak"].boolValue
            self.postNew = json["postNew"].boolValue
            self.postCommented = json["postCommented"].boolValue
            self.postLiked = json["postLiked"].boolValue
            self.postBookmarked = json["postBookmarked"].boolValue
            self.groupJoined = json["groupJoined"].boolValue
            self.groupLeft = json["groupLeft"].boolValue
        }
    }
}
