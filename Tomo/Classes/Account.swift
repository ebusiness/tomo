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

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveFriendInvitation:", name: ListenerEvent.FriendInvited.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFriendInvitationAccepted:", name: ListenerEvent.FriendAccepted.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFriendInvitationRefused:", name: ListenerEvent.FriendRefused.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFriendBroke:", name: ListenerEvent.FriendBreak.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMessage:", name: ListenerEvent.Message.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMessage:", name: ListenerEvent.GroupMessage.rawValue, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - Friend

extension Account {

    // Accept the make friend invitation
    func acceptInvitation(invitation: NotificationEntity) {

        // the invitation must exist
        guard let index = self.friendInvitations.indexOf(invitation) else { return }

        let friends = self.friends ?? []

        // my friends list must not contain the invitation sender
        guard !friends.contains(invitation.from.id) else { return }

        // remove invitation from account model
        self.friendInvitations.remove(invitation)
        // add new friend to accout model
        self.friends?.append(invitation.from.id)

        // tell every observer the changes: which invitation was deleted, and who is the new friend
        NSNotificationCenter.defaultCenter().postNotificationName("didAcceptInvitation", object: self, userInfo: ["indexOfRemovedInvitation": index, "userEntityOfNewFriend": invitation.from])
    }

    // Refuse the make friend invitation
    func refuseInvitation(invitation: NotificationEntity) {

        // the invitation must exist
        guard let index = self.friendInvitations.indexOf(invitation) else { return }

        // remove invitation from account model
        self.friendInvitations.remove(invitation)

        // tell every observer the changes: which invitation was deleted.
        NSNotificationCenter.defaultCenter().postNotificationName("didRefuseInvitation", object: self, userInfo: ["indexOfRemovedInvitation": index])
    }

    // Delete friend
    func deleteFriend(user: UserEntity) {

        // TODO: my friends list is a list of id string, this may not right!

        let friends = self.friends ?? []

        // my friends list must contain the user that will be deleted
        guard friends.contains(user.id) else { return }

        // remove this user from my friends list
        self.friends?.remove(user.id)

        // tell every observer the changes: which friend was deleted.
        NSNotificationCenter.defaultCenter().postNotificationName("didDeleteFriend", object: self, userInfo: ["idOfDeletedFriend": user.id])
    }

    func joinGroup(group: GroupEntity) {

        // TODO: my groups list is a list of id string, this may not right!

        let groups = self.groups ?? []

        // my groups list must not contain the group will be joined
        guard !groups.contains(group.id) else { return }

        // add the group into my group list
        self.groups?.append(group.id)

        // tell every observer the changes: which group was joined
        NSNotificationCenter.defaultCenter().postNotificationName("didJoinGroup", object: self, userInfo: ["groupEntityOfNewGroup": group])
    }

    func leaveGroup(group: GroupEntity) {

        // TODO: my groups list is a list of id string, this may not right!

        let groups = self.groups ?? []

        // my groups list must contain the group will be left
        guard groups.contains(group.id) else { return }

        // remove the group from my groups list
        self.groups?.remove(group.id)

        // tell every observer the changes: which group was left
        NSNotificationCenter.defaultCenter().postNotificationName("didLeaveGroup", object: self, userInfo: ["idOfDeletedGroup": group.id])
    }

    func sendMessage(message: MessageEntity) {
        NSNotificationCenter.defaultCenter().postNotificationName("didSendMessage", object: self, userInfo: ["messageEntityOfNewMessage": message])
    }
}

// MARK: - Remote Notification

extension Account {

    func didReceiveFriendInvitation(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }

        // create invitation
        let invitation = NotificationEntity(userInfo)
        // NOTE: here the notification entity's id is the userInfo's targetId,
        // cause the invitation was pushed as the form of notification. This may need revise
        invitation.id = invitation.targetId

        // insert invitation into my invitations list
        self.friendInvitations.insert(invitation, atIndex: 0)

        // tell every observer the changes: which invitation was added.
        NSNotificationCenter.defaultCenter().postNotificationName("didReceiveFriendInvitation", object: self)
    }

    func didFriendInvitationAccepted(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }

        // create notification
        let notification = NotificationEntity(userInfo)

        let friends = self.friends ?? []

        // my friends list must not contain the notification sender
        guard !friends.contains(notification.from.id) else { return }

        // remove the user from my inviting list
        self.invitations?.remove(notification.from.id)
        // asdd the user to my friends list
        self.friends?.insert(notification.from.id, atIndex: 0)

        NSNotificationCenter.defaultCenter().postNotificationName("didMyFriendInvitationAccepted", object: self, userInfo: ["idOfRemovedMyInvitation": notification.from.id, "userEntityOfNewFriend": notification.from])
    }

    func didFriendInvitationRefused(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }

        // create notification
        let notification = NotificationEntity(userInfo)

        let friends = self.friends ?? []

        // my friends list must not contain the notification sender
        guard !friends.contains(notification.from.id) else { return }

        // remove the user from my inviting list
        self.invitations?.remove(notification.from.id)

        NSNotificationCenter.defaultCenter().postNotificationName("didMyFriendInvitationRefused", object: self, userInfo: ["idOfRemovedMyInvitation": notification.from.id])
    }

    func didFriendBroke(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }

        // create notification
        let notification = NotificationEntity(userInfo)

        let friends = self.friends ?? []

        // my friends list must contain the notification sender
        guard friends.contains(notification.from.id) else { return }

        // remove the user from my inviting list
        self.friends?.remove(notification.from.id)

        NSNotificationCenter.defaultCenter().postNotificationName("didFriendBreak", object: self, userInfo: ["userIdOfBrokenFriend": notification.from.id])
    }

    func didReceiveMessage(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }

        // create message
        let message = MessageEntity(userInfo)

        // put the message in my new message list
        self.newMessages.push(message)

        NSNotificationCenter.defaultCenter().postNotificationName("didReceiveMessage", object: self, userInfo: ["messageEntityOfNewMessage": message])
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
