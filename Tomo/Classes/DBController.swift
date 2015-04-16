//
//  DBController.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/27.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class DBController: NSObject {
   
//    class var context: NSManagedObjectContext {
//        return RKObjectManager.sharedManager().managedObjectStore.persistentStoreManagedObjectContext
//    }
    
    // MARK: - Post
    
    class func postById(postId: String) -> Post {
        return Post.MR_findFirstByAttribute("id", withValue: postId) as! Post
    }
    
    class func newsfeeds(user: User? = nil) -> NSFetchedResultsController {
        if let user = user {
            return Post.MR_fetchAllGroupedBy(nil, withPredicate: NSPredicate(format: "owner=%@", user), sortedBy: "createDate", ascending: false)
        }
        
        return Post.MR_fetchAllGroupedBy(nil, withPredicate: nil, sortedBy: "createDate", ascending: false)
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
    
    // MARK: - Friend
    
    class func friends() -> [User] {
        let me = myUser()
        return me.friends.array as! [User]
    }
    
    class func clearDB() {
        Comments.MR_truncateAll()
        Devices.MR_truncateAll()
        Group.MR_truncateAll()
        Images.MR_truncateAll()
        Message.MR_truncateAll()
        Post.MR_truncateAll()
        User.MR_truncateAll()
        
        save()
    }
    
    
    class func save(done: (() -> Void)? = nil) {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion { (b, error) -> Void in
            done?()
        }
    }
}
