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
    
    class func newsfeeds() -> NSFetchedResultsController {
        return Post.MR_fetchAllGroupedBy(nil, withPredicate: nil, sortedBy: "createDate", ascending: false, inContext: context)
    }
    
//    class func newsfeeds(key: String, value: String) -> Post? {
//        return nil
//    }
    
    class func newsfeedsHasImage() -> [Post]? {
        let p = NSPredicate(format: "imagesmobile.count = 0", argumentArray: nil)
       return Post.MR_findAllWithPredicate(p, inContext: context) as? [Post]
    }
    
    class func allNewsfeeds() -> [Post]? {
        let res = Post.MR_findAllInContext(context)
        return Post.MR_findAllInContext(context) as? [Post]
    }
}
