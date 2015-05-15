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
    
    class func newsfeeds() -> NSFetchedResultsController {
        return Post.MR_fetchAllGroupedBy(nil, withPredicate: NSPredicate(format: "createDate != nil AND newsfeed = 1"), sortedBy: "createDate", ascending: false)
    }
    
    class func myPosts() -> NSFetchedResultsController {
        return Post.MR_fetchAllGroupedBy(nil, withPredicate: NSPredicate(format: "owner = %@ AND createDate != nil", myUser()!), sortedBy: "createDate", ascending: false)
    }
    
    // MARK: - User
    
    class func myUser() -> User? {
        if let myId = Defaults["myId"].string {
            return User.MR_findFirstByAttribute("id", withValue: myId) as? User
        }
        
        return nil
    }
    
    class func createUser(#email: String, id: String) {
        let user = User.MR_createEntity() as! User
        user.email = email
        user.id = id
        save()
    }
    
    class func users() -> [User] {
        if let me = myUser() {
            return User.MR_findAllWithPredicate(NSPredicate(format: "self != %@ AND (NOT (self IN %@ OR self IN %@))", me, me.friends, me.invited.array)) as! [User]
        }
        
        return [User]()
    }
    
    // MARK: - Friend
    
    class func friends() -> [User] {
        if let me = myUser() {
            var friends = me.friends.array as! [User]
            friends.sort({if let date1 = $0.createDate, let date2 = $1.createDate {
                return date1.timeIntervalSinceNow > date2.timeIntervalSinceNow
                }
                
                return false
            })
            return friends
        }
        
        return [User]()
    }
    
    class func invitedUsers() -> [User] {
        if let me = myUser() {
            return me.invited.array as! [User]
        }
        
        return [User]()
    }
    
    class func isInvitedUser(user: User) -> Bool {
        return find(invitedUsers(), user) != nil
    }
    
    class func isFriend(user: User) -> Bool {
        return find(friends(), user) != nil
    }
    
    // MARK: - Notification
    
    class func unconfirmedNotification(#type: NotificationType) -> [Notification] {
        if let me = myUser() {
        
           return Notification.MR_findAllSortedBy("createDate", ascending: false, withPredicate: NSPredicate(format: "type = %@ AND (confirmed.@count = 0 OR (NONE confirmed = %@))", type.rawValue, me)) as! [Notification]
        }
        
        return [Notification]()
    }
    
    // MARK: - Station
    
    class func myStation() -> Station? {
        return stationByName(myUser()?.nearestSt)
    }
    
    class func stations() -> NSFetchedResultsController {
        return Station.MR_fetchAllGroupedBy(nil, withPredicate: nil, sortedBy: "zipcode", ascending: true)
    }
    
    class func stationByName(name: String?) -> Station? {
        if let name = name {
            return Station.MR_findFirstByAttribute("name", withValue: name) as? Station
        }
        
        return nil
    }
    
    // MARK: - Group
    
    class func groups(station: String?, onlyMe: Bool = false) -> NSFetchedResultsController {
        let fetchRequest = NSFetchRequest(entityName: "Group")
        let sort1 = NSSortDescriptor(key: "section", ascending: true)
        let sort2 = NSSortDescriptor(key: "createDate", ascending: false)
        fetchRequest.sortDescriptors = [sort1, sort2]
        if let station = station {
            fetchRequest.predicate = NSPredicate(format: "createDate != nil && station.id = %@",station)
        } else{
            fetchRequest.predicate = NSPredicate(format: "createDate != nil")
        }
        
        var filterPredicate: NSPredicate
        
        if onlyMe {
            filterPredicate = NSPredicate(format: "section = 1")
        } else {
            filterPredicate = NSPredicate(format: "section > 0")
        }
        
        fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [fetchRequest.predicate!, filterPredicate])
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSManagedObjectContext.MR_defaultContext(), sectionNameKeyPath: "section", cacheName: nil)
        return frc
    }
    
    // MARK: - Message
    
    class func createMessage(user: User, text: String) {
        let message = Message.MR_createEntity() as! Message
        message.to = NSOrderedSet(array: [user])
        message.content = text
        message.subject = "no subject"
        message.from = myUser()
        message.createDate = NSDate()
        
        save()
    }
    
    class func createMessageGroup(group: Group, text: String) {
        let message = Message.MR_createEntity() as! Message
        
//        var to = [User]()
//        
//        for user in group.participants.array as! [User] {
//            if user.id != myUser()?.id {
//                to.append(user)
//            }
//        }
        
//        message.to = NSOrderedSet(array: to)
        message.group = group
        message.content = text
        message.subject = "no subject"
        message.from = myUser()
        message.createDate = NSDate()
        
        save()
    }
    
    class func lastMessage(user: User) -> Message? {
        return Message.MR_findFirstWithPredicate(NSPredicate(format: "group = NULL AND (from=%@ OR ANY to.id=%@)", user, user.id!), sortedBy: "createDate", ascending: false) as? Message
    }
    
    //for local notification
    class func latestMessage() -> Message? {
        return Message.MR_findFirstWithPredicate(NSPredicate(format: "group = NULL"), sortedBy: "createDate", ascending: false) as? Message
    }
    
    class func unreadCount(user: User) -> Int {
        return Int(bitPattern: Message.MR_countOfEntitiesWithPredicate(NSPredicate(format: "group = NULL AND from=%@ AND isRead=NO", user)))
    }
    
    class func unreadCountTotal() -> Int {
        if let me = myUser() {
            return Int(bitPattern: Message.MR_countOfEntitiesWithPredicate(NSPredicate(format: "group = NULL AND from!=%@ AND isRead=NO", me)))
        }
        
        return 0
    }
    
    class func makeAllMessageRead(user: User) {
        let messages = Message.MR_findAllWithPredicate(NSPredicate(format: "from=%@ AND group = NULL", user)) as! [Message]
        for message in messages {
            message.isRead = true
        }
        
        save()
    }
    
    class func makeAllMessageGroupRead(group: Group) {
        let messages = Message.MR_findAllWithPredicate(NSPredicate(format: "group = %@", group)) as! [Message]
        for message in messages {
            message.isRead = true
        }
        
        save()
    }
    
    class func messageWithUser(user: User) -> NSFetchedResultsController {
        return Message.MR_fetchAllGroupedBy(nil, withPredicate: NSPredicate(format: "group = NULL AND (from=%@ OR ANY to.id=%@)", user, user.id!), sortedBy: "createDate", ascending: true)
    }
    
    class func messageWithGroup(group: Group) -> NSFetchedResultsController {
        return Message.MR_fetchAllGroupedBy(nil, withPredicate: NSPredicate(format: "group = %@", group), sortedBy: "createDate", ascending: true)
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
        
        Defaults.remove("didGetMessageSent")
        
        save()
    }
    
    class func clearDBForLogout() {
        Openids.MR_truncateAll()
        save { () -> Void in
            OpenidController.instance.registQQ()
        }
        
        Defaults["email"] = ""
        Defaults["shouldAutoLogin"] = false
        
        //remove device
        ApiController.setDeviceInfo(nil, done: { (error) -> Void in
            Manager.sharedInstance.request(.POST, kAPIBaseURLString + "/logout", parameters: nil, encoding: ParameterEncoding.URL)
        })
    }
}
