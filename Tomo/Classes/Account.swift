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

        NotificationCenter.default.addObserver(self, selector: #selector(Account.didReceiveFriendInvitation(_:)), name: ListenerEvent.FriendInvited.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Account.didFriendInvitationAccepted(_:)), name: ListenerEvent.FriendAccepted.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Account.didFriendInvitationRefused(_:)), name: ListenerEvent.FriendRefused.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Account.didFriendBroke(_:)), name: ListenerEvent.FriendBreak.notificationName, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Account.didReceiveMessage(_:)), name: ListenerEvent.Message.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Account.didReceiveMessage(_:)), name: ListenerEvent.GroupMessage.notificationName, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(Account.didReceivePost(_:)), name: ListenerEvent.PostNew.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Account.didPostLiked(_:)), name: ListenerEvent.PostLiked.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Account.didPostCommented(_:)), name: ListenerEvent.PostCommented.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Account.didPostBookmarked(_:)), name: ListenerEvent.PostBookmarked.notificationName, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Friend

extension Account {

    // Accept the make friend invitation
    func acceptInvitation(invitation: NotificationEntity) {

        // the invitation must exist
        guard let index = self.friendInvitations.index(of: invitation) else { return }

        let friends = self.friends ?? []

        // my friends list must not contain the invitation sender
        guard !friends.contains(invitation.from.id) else { return }

        // remove invitation from account model
        if let index = self.friendInvitations.index(of: invitation) {
            self.friendInvitations.remove(at: index)
        }
        // add new friend to accout model
        self.friends?.append(invitation.from.id)

        // tell every observer the changes: which invitation was deleted, and who is the new friend
        let name = NSNotification.Name(rawValue: "didAcceptInvitation")
        let userInfo: [String : Any] = [
            "indexOfRemovedInvitation": index,
            "userEntityOfNewFriend": invitation.from
        ]
        NotificationCenter.default.post(name: name, object: self, userInfo: userInfo)
    }

    // Refuse the make friend invitation
    func refuseInvitation(invitation: NotificationEntity) {

        // the invitation must exist
        guard let index = self.friendInvitations.index(of: invitation) else { return }

        // remove invitation from account model
        if let index = self.friendInvitations.index(of: invitation) {
            self.friendInvitations.remove(at: index)
        }

        // tell every observer the changes: which invitation was deleted.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didRefuseInvitation"), object: self, userInfo: ["indexOfRemovedInvitation": index])
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
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didDeleteFriend"), object: self, userInfo: ["idOfDeletedFriend": user.id])
    }

    func joinGroup(group: GroupEntity) {

        // TODO: my groups list is a list of id string, this may not right!

        let groups = self.groups ?? []

        // my groups list must not contain the group will be joined
        guard !groups.contains(group.id) else { return }

        // add the group into my group list
        self.groups?.append(group.id)

        // tell every observer the changes: which group was joined
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didJoinGroup"), object: self, userInfo: ["groupEntityOfNewGroup": group])
    }

    func leaveGroup(group: GroupEntity) {

        // TODO: my groups list is a list of id string, this may not right!

        let groups = self.groups ?? []

        // my groups list must contain the group will be left
        guard groups.contains(group.id) else { return }

        // remove the group from my groups list
        self.groups?.remove(group.id)

        // tell every observer the changes: which group was left
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didLeaveGroup"), object: self, userInfo: ["idOfDeletedGroup": group.id])
    }

    func sendMessage(message: MessageEntity) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didSendMessage"), object: self, userInfo: ["messageEntityOfNewMessage": message])
    }

    func finishChat(user: UserEntity) {

        // remove all the message from this user in new messages list, cause we finished talk
        me.newMessages = me.newMessages.filter {

            // skip group message
            guard $0.group == nil else { return true }

            let from = ($0.from.id == me.id ? $0.to : $0.from)
            return from!.id != user.id
        }

        // tell every observer the changes: which user talked with
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didFinishChat"), object: self, userInfo: ["idOfTalkedFriend": user.id])
    }

    func finishGroupChat(group: GroupEntity) {

        // remove all the message from this group in new messages list, cause we finished talk
        me.newMessages = me.newMessages.filter {

            // skip normal message
            guard $0.group != nil else { return true }
            return $0.group!.id != group.id
        }

        // tell every observer the changes: which user talked with
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didFinishGroupChat"), object: self, userInfo: ["idOfTalkedGroup": group.id])
    }

    func checkAllNotification() {
        me.notifications = 0

        // tell every observer the changes: all notification checked
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didCheckAllNotification"), object: self, userInfo: nil)
    }

    func editProfile() {
        // tell every observer the changes: my profile changed
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didEditProfile"), object: self, userInfo: nil)
    }
}

// MARK: - Remote Notification

extension Account {

    func didReceiveFriendInvitation(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }

        // create invitation
        let invitation = NotificationEntity(userInfo)
        // NOTE: here the notification entity's id is the userInfo's targetId,
        // cause the invitation was pushed as the form of notification. This may need revise
        invitation.id = invitation.targetId

        // insert invitation into my invitations list
        self.friendInvitations.insert(invitation, at: 0)

        // tell every observer the changes: which invitation was added.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didReceiveFriendInvitation"), object: self, userInfo: nil)
    }

    func didFriendInvitationAccepted(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }

        // create notification
        let notification = NotificationEntity(userInfo)

        let friends = self.friends ?? []

        // my friends list must not contain the notification sender
        guard !friends.contains(notification.from.id) else { return }
        
        var postUserInfo = ["idOfRemovedMyInvitation": notification.from.id, "userEntityOfNewFriend": notification.from] as [String : Any]

        // remove the user from my inviting list
        self.invitations?.remove(notification.from.id)
        
        // remove the user from the list of invited me
        if let index = self.friendInvitations.index(where: { $0.from.id == notification.from.id }) {
            self.friendInvitations.remove(at: index)
            postUserInfo["indexOfRemovedInvitation"] = index
        }
        
        // asdd the user to my friends list
        self.friends?.insert(notification.from.id, at: 0)

        self.notifications! += 1

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didMyFriendInvitationAccepted"), object: self, userInfo: postUserInfo)
    }

    func didFriendInvitationRefused(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }

        // create notification
        let notification = NotificationEntity(userInfo)

        let friends = self.friends ?? []

        // my friends list must not contain the notification sender
        guard !friends.contains(notification.from.id) else { return }

        // remove the user from my inviting list
        self.invitations?.remove(notification.from.id)

        self.notifications! += 1

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didMyFriendInvitationRefused"), object: self, userInfo: ["idOfRemovedMyInvitation": notification.from.id])
    }

    func didFriendBroke(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }

        // create notification
        let notification = NotificationEntity(userInfo)

        let friends = self.friends ?? []

        // my friends list must contain the notification sender
        guard friends.contains(notification.from.id) else { return }

        // remove the user from my inviting list
        self.friends?.remove(notification.from.id)

        self.notifications! += 1

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didFriendBreak"), object: self, userInfo: ["userIdOfBrokenFriend": notification.from.id])
    }

    func didReceiveMessage(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }

        // create message
        let message = MessageEntity(userInfo)

        // put the message in my new message list
        self.newMessages.append(message)

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didReceiveMessage"), object: self, userInfo: ["messageEntityOfNewMessage": message])
    }

    func didReceivePost(_ notification: NSNotification) {

        self.notifications! += 1

        // TODO: I haven't do anything about this event yet!
        // just relay it and tell setting screen update it's badge
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didReceivePost"), object: self, userInfo: nil)
    }

    func didPostLiked(_ notification: NSNotification) {

        self.notifications! += 1

        // TODO: I haven't do anything about this event yet!
        // just relay it and tell setting screen update it's badge
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didPostLiked"), object: self, userInfo: nil)
    }

    func didPostCommented(_ notification: NSNotification) {

        self.notifications! += 1

        // TODO: I haven't do anything about this event yet!
        // just relay it and tell setting screen update it's badge
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didPostCommented"), object: self, userInfo: nil)
    }

    func didPostBookmarked(_ notification: NSNotification) {

        self.notifications! += 1

        // TODO: I haven't do anything about this event yet!
        // just relay it and tell setting screen update it's badge
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didPostBookmarked"), object: self, userInfo: nil)
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
