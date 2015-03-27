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
        return Newsfeed.MR_fetchAllGroupedBy(nil, withPredicate: nil, sortedBy: "createDate", ascending: false, inContext: context)
    }
    
}
