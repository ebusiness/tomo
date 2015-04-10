//
//  DBController.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/27.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class DBController: NSObject {
   
    class var context: NSManagedObjectContext {
        return RKObjectManager.sharedManager().managedObjectStore.persistentStoreManagedObjectContext
    }
    
    // MARK: - Post
    
    class func postById(postId: String) -> Post {
        return Post.MR_findFirstByAttribute("id", withValue: postId, inContext: context) as! Post
    }
    
    class func newsfeeds() -> NSFetchedResultsController {
        return Post.MR_fetchAllGroupedBy(nil, withPredicate: nil, sortedBy: "createDate", ascending: false, inContext: context)
    }
    
    class func newsfeedsHasImage() -> [Post]? {
        let p = NSPredicate(format: "imagesmobile.count = 0", argumentArray: nil)
       return Post.MR_findAllWithPredicate(p, inContext: context) as? [Post]
    }
    
    class func allNewsfeeds() -> [Post]? {
        let res = Post.MR_findAllInContext(context)
        return Post.MR_findAllInContext(context) as? [Post]
    }
    
    // MARK: - User
    
    class func myUser() -> User {
        return User.MR_findFirstByAttribute("id", withValue: Defaults["myId"].string!, inContext: context) as! User
    }
    
    // MARK: - Friend
    
    class func friends() -> [User] {
        let me = myUser()
        return me.friends.array as! [User]
    }
}
