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

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceivePost:", name: ListenerEvent.PostNew.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didPostLiked:", name: ListenerEvent.PostLiked.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didPostCommented:", name: ListenerEvent.PostCommented.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didPostBookmarked:", name: ListenerEvent.PostBookmarked.rawValue, object: nil)
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

    func finishChat(user: UserEntity) {

        // remove all the message from this user in new messages list, cause we finished talk
        me.newMessages = me.newMessages.filter {

            // skip group message
            guard $0.group == nil else { return true }

            let from = ($0.from.id == me.id ? $0.to : $0.from)
            return from.id != user.id
        }

        // tell every observer the changes: which user talked with
        NSNotificationCenter.defaultCenter().postNotificationName("didFinishChat", object: self, userInfo: ["idOfTalkedFriend": user.id])
    }

    func finishGroupChat(group: GroupEntity) {

        // remove all the message from this group in new messages list, cause we finished talk
        me.newMessages = me.newMessages.filter {

            // skip normal message
            guard $0.group != nil else { return true }
            return $0.group!.id != group.id
        }

        // tell every observer the changes: which user talked with
        NSNotificationCenter.defaultCenter().postNotificationName("didFinishGroupChat", object: self, userInfo: ["idOfTalkedGroup": group.id])
    }

    func checkAllNotification() {
        me.notifications = 0

        // tell every observer the changes: all notification checked
        NSNotificationCenter.defaultCenter().postNotificationName("didCheckAllNotification", object: self, userInfo: nil)
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
        
        var postUserInfo = ["idOfRemovedMyInvitation": notification.from.id, "userEntityOfNewFriend": notification.from]

        // remove the user from my inviting list
        self.invitations?.remove(notification.from.id)
        
        // remove the user from the list of invited me
        if let index = self.friendInvitations.indexOf({ $0.from.id == notification.from.id }) {
            self.friendInvitations.removeAtIndex(index)
            postUserInfo["indexOfRemovedInvitation"] = index
        }
        
        // asdd the user to my friends list
        self.friends?.insert(notification.from.id, atIndex: 0)

        self.notifications = self.notifications + 1

        NSNotificationCenter.defaultCenter().postNotificationName("didMyFriendInvitationAccepted", object: self, userInfo: postUserInfo)
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

        self.notifications = self.notifications + 1

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

        self.notifications = self.notifications + 1

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

    func didReceivePost(notification: NSNotification) {

        self.notifications = self.notifications + 1

        // TODO: I haven't do anything about this event yet!
        // just relay it and tell setting screen update it's badge
        NSNotificationCenter.defaultCenter().postNotificationName("didReceivePost", object: self, userInfo: nil)
    }

    func didPostLiked(notification: NSNotification) {

        self.notifications = self.notifications + 1

        // TODO: I haven't do anything about this event yet!
        // just relay it and tell setting screen update it's badge
        NSNotificationCenter.defaultCenter().postNotificationName("didPostLiked", object: self, userInfo: nil)
    }

    func didPostCommented(notification: NSNotification) {

        self.notifications = self.notifications + 1

        // TODO: I haven't do anything about this event yet!
        // just relay it and tell setting screen update it's badge
        NSNotificationCenter.defaultCenter().postNotificationName("didPostCommented", object: self, userInfo: nil)
    }

    func didPostBookmarked(notification: NSNotification) {

        self.notifications = self.notifications + 1

        // TODO: I haven't do anything about this event yet!
        // just relay it and tell setting screen update it's badge
        NSNotificationCenter.defaultCenter().postNotificationName("didPostBookmarked", object: self, userInfo: nil)
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
