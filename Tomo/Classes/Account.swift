//
//  Me.swift
//  Tomo
//
//  Created by starboychina on 2016/01/18.
//  Copyright © 2016年 &#24373;&#24535;&#33775;. All rights reserved.
//

import SwiftyJSON
class Account: UserEntity {
    
    private var friendsClosures = Array<([UserEntity], [UserEntity]) -> ()>()
    private var groupsClosures = Array<([GroupEntity], [GroupEntity]) -> ()>()
    private var friendInvitationsClosures = Array<([NotificationEntity], [NotificationEntity]) -> ()>()
    
    private var cacheData = [String: NSObject]() // mongodb->ObjectId : userEntity/GroupEntity
    
    
    var telNo: String?
    
    var friends: [String]? {
        didSet{
            gcd.async(.Default){
                let (addValues, removeValues) = Util.diff(oldValue, rightValue: self.friends)
                var addedFriends = [UserEntity]()
                addValues.forEach({
                    guard let uid = $0 as? String else { return }
                    guard let user = self.cacheData[uid] as? UserEntity else { return }
                    addedFriends.append(user)
                })
                
                var removedFriends = [UserEntity]()
                removeValues.forEach({
                    guard let uid = $0 as? String else { return }
                    if let user = self.cacheData[uid] as? UserEntity {
                        removedFriends.append(user)
                    } else {
                        let user = UserEntity()
                        user.id = uid
                        removedFriends.append(user)
                    }
                })
                self.friendsClosures.forEach {
                    $0(addedFriends, removedFriends)
                }
                self.cacheData = self.cacheData.filter({ !($0.1 is UserEntity) })
            }
        }
    }
    
    var groups: [String]? {
        didSet{
            gcd.async(.Default){
                let (addValues, removeValues) = Util.diff(oldValue, rightValue: self.groups)
                var addedGroups = [GroupEntity]()
                addValues.forEach({
                    guard let gid = $0 as? String else { return }
                    guard let group = self.cacheData[gid] as? GroupEntity else { return }
                    addedGroups.append(group)
                })
                
                var removedGroups = [GroupEntity]()
                removeValues.forEach({
                    guard let gid = $0 as? String else { return }
                    if let group = self.cacheData[gid] as? GroupEntity {
                        removedGroups.append(group)
                    } else {
                        let group = GroupEntity()
                        group.id = gid
                        removedGroups.append(group)
                    }
                })
                self.groupsClosures.forEach {
                    $0(addedGroups, removedGroups)
                }
                self.cacheData = self.cacheData.filter({ !($0.1 is GroupEntity) })
            }
        }
    }
    
    var invitations: [String]?
    
    var blockUsers: [String]?
    
    var friendInvitations: [NotificationEntity]! {
        didSet{
            gcd.async(.Default){
                let (addValues, removeValues) = Util.diff(oldValue, rightValue: self.friendInvitations)
                guard let add = addValues as? [NotificationEntity] else { return }
                guard let remove = removeValues as? [NotificationEntity] else { return }
                self.friendInvitationsClosures.forEach {
                    $0(add, remove)
                }
            }
        }
    }
    
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
    func addFriend(user: UserEntity) -> Bool{
        self.cacheData[user.id] = user
        
        self.invitations?.remove(user.id)
        let friendInvitations = self.friendInvitations.filter { $0.from.id != user.id }
        self.friendInvitations = friendInvitations
        
        var friends = self.friends ?? []
        
        if friends.contains(user.id) {
            return false
        } else {
            friends.append(user.id)
            self.friends = friends
            return true
        }
    }
    
    func removeFriend(user: UserEntity){
        self.cacheData[user.id] = user
        
        self.invitations?.remove(user.id)
        let friendInvitations = self.friendInvitations.filter { $0.from.id != user.id }
        self.friendInvitations = friendInvitations
        self.newMessages = self.newMessages.filter { $0.from.id != user.id }
        self.friends?.remove(user.id)
    }
}
// MARK: - group
extension Account {
    func addGroup(group: GroupEntity) {
        var groups = self.groups ?? []
        
        if groups.contains(group.id) { return }
        
        self.cacheData[group.id] = group
        groups.append(group.id)
        
        self.groups = groups
    }
    
    func removeGroup(group: GroupEntity) {
        var groups = self.groups ?? []
        
        if !groups.contains(group.id) { return }
        
        self.cacheData[group.id] = group
        groups.remove(group.id)
        
        self.groups = groups
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

extension Account {
    func addFriendsObserver(closure : ([UserEntity], [UserEntity]) -> ()) {
        friendsClosures.append(closure)
    }
    
    func addGroupsObserver(closure : ([GroupEntity], [GroupEntity]) -> ()) {
        groupsClosures.append(closure)
    }
    
    func addFriendInvitationsObserver(closure : ([NotificationEntity], [NotificationEntity]) -> ()) {
        friendInvitationsClosures.append(closure)
    }

}
