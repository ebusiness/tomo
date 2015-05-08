//
//  DBController.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/27.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

enum NotificationType: String {
    case FriendInvited = "friend-invited"
}

class DBController: NSObject {
   
//    class var context: NSManagedObjectContext {
//        return RKObjectManager.sharedManager().managedObjectStore.persistentStoreManagedObjectContext
//    }
    
    // MARK: - Post
    
    class func postById(postId: String) -> Post {
        return Post.MR_findFirstByAttribute("id", withValue: postId) as! Post
    }
    
    class func newsfeeds(user: User?) -> NSFetchedResultsController {
        if let user = user {
            return Post.MR_fetchAllGroupedBy(nil, withPredicate: NSPredicate(format: "owner=%@ AND createDate != nil", user), sortedBy: "createDate", ascending: false)
        }
        
        return Post.MR_fetchAllGroupedBy(nil, withPredicate: NSPredicate(format: "createDate != nil"), sortedBy: "createDate", ascending: false)
    }
    
    // MARK: - User
    
    class func myUser() -> User {
        return User.MR_findFirstByAttribute("id", withValue: Defaults["myId"].string!) as! User
    }
    
    class func createUser(#email: String, id: String) {
        let user = User.MR_createEntity() as! User
        user.email = email
        user.id = id
        save()
    }
    
    class func users() -> [User] {
        let me = myUser()
        return User.MR_findAllWithPredicate(NSPredicate(format: "self != %@ AND (NOT (self IN %@ OR self IN %@))", me, me.friends, me.invited.array)) as! [User]
    }
    
    // MARK: - Friend
    
    class func friends() -> [User] {
        let me = myUser()
        var friends = me.friends.array as! [User]
        friends.sort({if let date1 = $0.createDate, let date2 = $1.createDate {
            return date1.timeIntervalSinceNow > date2.timeIntervalSinceNow
            }
            
            return false
        })
        return friends
    }
    
    class func invitedUsers() -> [User] {
        let me = myUser()
        return me.invited.array as! [User]
    }
    
    class func isInvitedUser(user: User) -> Bool {
        return find(invitedUsers(), user) != nil
    }
    
    class func isFriend(user: User) -> Bool {
        return find(friends(), user) != nil
    }
    
    // MARK: - Notification
    
    class func unconfirmedNotification(#type: NotificationType) -> [Notification] {
        let me = myUser()
        
       return Notification.MR_findAllSortedBy("createDate", ascending: false, withPredicate: NSPredicate(format: "type = %@ AND (confirmed.@count = 0 OR (NONE confirmed = %@))", type.rawValue, me)) as! [Notification]
//        return Notification.MR_findByAttribute("type", withValue: type.rawValue, andOrderBy: "createDate", ascending: false) as! [Notification]
    }
    
    // MARK: - Station
    
    class func stations() -> NSFetchedResultsController {
        return Station.MR_fetchAllGroupedBy(nil, withPredicate: nil, sortedBy: "zipcode", ascending: true)
    }
    
    class func stationByName(name: String) -> Station? {
        return Station.MR_findFirstByAttribute("name", withValue: name) as? Station
    }
    
    // MARK: - Group
    
    class func groups(station:String) -> NSFetchedResultsController {
//        return Group.MR_fetchAllGroupedBy(nil, withPredicate: NSPredicate(format: "createDate != nil"), sortedBy: "createDate", ascending: false)
        
//        return Group.MR_fetchAllGroupedBy("section", withPredicate: NSPredicate(format: "createDate != nil"), sortedBy: "createDate", ascending: false)
        
//        return Group.MR_fetchAllSortedBy("createDate, section", ascending: false, withPredicate: NSPredicate(format: "createDate != nil"), groupBy: "section", delegate: nil)
        
        let fetchRequest = NSFetchRequest(entityName: "Group")
        let sort1 = NSSortDescriptor(key: "section", ascending: true)
        let sort2 = NSSortDescriptor(key: "createDate", ascending: false)
        fetchRequest.sortDescriptors = [sort1, sort2]
        if (station.isEmpty){
            fetchRequest.predicate = NSPredicate(format: "createDate != nil AND section > 0 ")
        }else{
            fetchRequest.predicate = NSPredicate(format: "createDate != nil AND section > 0 && station.id = %@",station)
        }
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSManagedObjectContext.MR_defaultContext(), sectionNameKeyPath: "section", cacheName: nil)
        return frc
    }
    
    // MARK: - Message
    
    class func lastMessage(user: User) -> Message? {
        return Message.MR_findFirstWithPredicate(NSPredicate(format: "from=%@ OR (to.@count = 1 AND ANY to.id=%@)", user, user.id!), sortedBy: "createDate", ascending: false) as? Message
    }
    
    class func unreadCount(user: User) -> Int {
        return Int(bitPattern: Message.MR_countOfEntitiesWithPredicate(NSPredicate(format: "from=%@ AND isRead=NO", user)))
    }
    
    class func unreadCountTotal() -> Int {
        return Int(bitPattern: Message.MR_countOfEntitiesWithPredicate(NSPredicate(format: "from!=%@ AND isRead=NO", myUser())))
    }
    
    class func makeAllMessageRead(user: User) {
        let messages = Message.MR_findAllWithPredicate(NSPredicate(format: "from=%@", user)) as! [Message]
        for message in messages {
            message.isRead = true
        }
        
        save()
    }
    
    // MARK: - other
    
    class func save(done: (() -> Void)? = nil) {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion { (b, error) -> Void in
            done?()
        }
    }
    
    class func clearDB() {
        self.clearDBForLogout()
        Comments.MR_truncateAll()
        Devices.MR_truncateAll()
        Group.MR_truncateAll()
        Images.MR_truncateAll()
        Message.MR_truncateAll()
        Post.MR_truncateAll()
        User.MR_truncateAll()
        Notification.MR_truncateAll()
        Station.MR_truncateAll()
        Line.MR_truncateAll()
        save()
    }
    
    class func clearDBForLogout() {
        Openids.MR_truncateAll()
        OpenidController.instance.registQQ()
        save()
    }
}
