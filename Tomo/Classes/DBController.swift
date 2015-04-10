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
    
    class func newsfeeds() -> NSFetchedResultsController {
        return Post.MR_fetchAllGroupedBy(nil, withPredicate: nil, sortedBy: "createDate", ascending: false)
    }
    
    // MARK: - User
    
    class func myUser() -> User {
        return User.MR_findFirstByAttribute("id", withValue: Defaults["myId"].string!) as! User
    }
    
    // MARK: - Friend
    
    class func friends() -> [User] {
        let me = myUser()
        return me.friends.array as! [User]
    }
}
