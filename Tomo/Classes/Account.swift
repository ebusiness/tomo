//
//  Me.swift
//  Tomo
//
//  Created by starboychina on 2016/01/18.
//  Copyright © 2016年 &#24373;&#24535;&#33775;. All rights reserved.
//

import SwiftyJSON
class Account: UserEntity {
    
    private var friendsClosures = Array<([Int: UserEntity], [Int: UserEntity]) -> ()>()
    private var groupsClosures = Array<([Int: GroupEntity], [Int: GroupEntity]) -> ()>()
    
    private var cacheData = [String: NSObject]() // mongodb->ObjectId : userEntity/GroupEntity
    
    private var friendInvitationsClosures = Array<([Int: NotificationEntity], [Int: NotificationEntity]) -> ()>()
    
    var telNo: String?
    
    var friends: [String]? {
        didSet{
            gcd.async(.Default){
                let (addValues, removeValues) = self.diff(oldValue, newValue: self.friends)
                var addedFriends = [Int: UserEntity]()
                addValues.forEach({ (index, uid) -> () in
                    guard let uid = uid as? String else { return }
                    guard let user = self.cacheData[uid] as? UserEntity else { return }
                    addedFriends[index] = user
                })
                
                var removedFriends = [Int: UserEntity]()
                removeValues.forEach({ (index, uid) -> () in
                    guard let uid = uid as? String else { return }
                    guard let user = self.cacheData[uid] as? UserEntity else { return }
                    removedFriends[index] = user
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
                let (addValues, removeValues) = self.diff(oldValue, newValue: self.groups)
                var addedGroups = [Int: GroupEntity]()
                addValues.forEach({ (index, gid) -> () in
                    guard let gid = gid as? String else { return }
                    guard let group = self.cacheData[gid] as? GroupEntity else { return }
                    addedGroups[index] = group
                })
                
                var removedGroups = [Int: GroupEntity]()
                removeValues.forEach({ (index, gid) -> () in
                    guard let gid = gid as? String else { return }
                    guard let group = self.cacheData[gid] as? GroupEntity else { return }
                    removedGroups[index] = group
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
                let (addValues, removeValues) = self.diff(oldValue, newValue: self.friendInvitations)
                guard let add = addValues as? [Int: NotificationEntity] else { return }
                guard let remove = removeValues as? [Int: NotificationEntity] else { return }
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
    func addFriendsObserver(closure : ([Int: UserEntity], [Int: UserEntity]) -> ()) {
        friendsClosures.append(closure)
    }
    
    func addGroupsObserver(closure : ([Int: GroupEntity], [Int: GroupEntity]) -> ()) {
        groupsClosures.append(closure)
    }
    
    func addFriendInvitationsObserver(closure : ([Int: NotificationEntity], [Int: NotificationEntity]) -> ()) {
        friendInvitationsClosures.append(closure)
    }
    
    private func diff(oldValue: [NSObject]?, newValue: [NSObject]?) -> ([Int: NSObject], [Int: NSObject]) {
        let addedItems = self.objectChanged(oldValue, newValue: newValue)
        let removedItems = self.objectChanged(newValue, newValue: oldValue)
        
        return (addedItems, removedItems)
    }
    
    private func objectChanged(oldValue: [NSObject]?, newValue: [NSObject]?) -> [Int: NSObject] {
        var items = [Int: NSObject]()
        guard let newValue = newValue else { return items }
        
        let values = newValue.filter({ value in
            !(oldValue ?? []).contains({$0 == value})
        })
        
        values.forEach {
            items[newValue.indexOf($0)!] = $0
        }
        return items
    }

}
