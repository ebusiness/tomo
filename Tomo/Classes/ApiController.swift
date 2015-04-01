//
//  ApiController.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/26.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ApiController: NSObject {
   
    class func setup() {
        RKObjectManager(baseURL: kAPIBaseURL)
        
        let model = NSManagedObjectModel.mergedModelFromBundles(nil)
        let store = RKManagedObjectStore(managedObjectModel: model)
        RKObjectManager.sharedManager().managedObjectStore = store
        
        store.createPersistentStoreCoordinator()
        let storePath = RKApplicationDataDirectory().stringByAppendingPathComponent("Tomo.sqlite")
        let seedPath = NSBundle.mainBundle().pathForResource("RKSeedDatabase", ofType: "sqlite")
        
        let ps = store.addSQLitePersistentStoreAtPath(storePath, fromSeedDatabaseAtPath: seedPath, withConfiguration: nil, options: nil, error: nil)
        store.createManagedObjectContexts()
        
        store.managedObjectCache = RKInMemoryManagedObjectCache(managedObjectContext: store.persistentStoreManagedObjectContext)
        
        addUserResponseDescriptor()
        addUserInfoResponseDescriptor()
        addNewsfeedResponseDescriptor()
        
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
    }
    
    class func signUp(#email: String, password: String, firstName: String, lastName: String, done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().postObject(nil, path: "/mobile/user/regist", parameters: ["email" : email, "password" : password, "firstName" : firstName, "lastName" : lastName], success: { (_, result) -> Void in
            println(result)
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    class func loginWithUser(user: User, done: (NSError?) -> Void) {
        
    }
    
    class func login(#email: String, password: String, done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().postObject(nil, path: "/login", parameters: ["email" : email, "password" : password], success: { (_, result) -> Void in
            done(nil)
        }) { (_, error) -> Void in
            done(error)
        }
    }
    
    class func getUserInfo(id: String, done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().getObject(nil, path: "/users/\(id)", parameters: nil, success: { (_,result) -> Void in
            done(nil)
        }) { (_, error) -> Void in
            done(error)
        }
    }
    
    class func getNewsfeed(done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().getObjectsAtPath("/newsfeed", parameters: nil, success: { (_, _) -> Void in
            done(nil)
        }) { (_, error) -> Void in
            done(error)
        }
    }
    
    class func dicFromPlist(name: String) -> NSDictionary {
        let path = NSBundle.mainBundle().pathForResource(name, ofType: "plist")
        return NSDictionary(contentsOfFile: path!)!
    }
    
    // MARK: - Descriptor
    
    class func addUserResponseDescriptor() {
        let store = RKObjectManager.sharedManager().managedObjectStore
        
        let userMapping = RKEntityMapping(forEntityForName: "User", inManagedObjectStore: store)
        userMapping.identificationAttributes = ["id"]
        userMapping.addAttributeMappingsFromDictionary(dicFromPlist("UserMapping"))
        
        let userDescriptor = RKResponseDescriptor(mapping: userMapping, method: .POST, pathPattern: "/login", keyPath: nil, statusCodes: nil)
        
        RKObjectManager.sharedManager().addResponseDescriptor(userDescriptor)
    }
    
    class func addUserInfoResponseDescriptor() {
        let store = RKObjectManager.sharedManager().managedObjectStore
        
        let userInfoMapping = RKEntityMapping(forEntityForName: "UserInfo", inManagedObjectStore: store)
        userInfoMapping.identificationAttributes = ["id"]
        userInfoMapping.addAttributeMappingsFromDictionary(dicFromPlist("UserInfoMapping"))
        
        let postMapping = RKEntityMapping(forEntityForName: "Post", inManagedObjectStore: store)
        postMapping.identificationAttributes = ["id"]
        postMapping.addAttributeMappingsFromDictionary(dicFromPlist("PostMapping"))
        
        userInfoMapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "posts", toKeyPath: "posts", withMapping: postMapping))
        
        let userInfoDescriptor = RKResponseDescriptor(mapping: userInfoMapping, method: .GET, pathPattern: "/users/:id", keyPath: nil, statusCodes: nil)
        
        RKObjectManager.sharedManager().addResponseDescriptor(userInfoDescriptor)
    }
    
    class func addNewsfeedResponseDescriptor() {
        let store = RKObjectManager.sharedManager().managedObjectStore
        
        let newsfeedMapping = RKEntityMapping(forEntityForName: "Newsfeed", inManagedObjectStore: store)
        newsfeedMapping.identificationAttributes = ["id"]
        newsfeedMapping.addAttributeMappingsFromDictionary(dicFromPlist("NewsfeedMapping"))
        
        let newsfeedDescriptor = RKResponseDescriptor(mapping: newsfeedMapping, method: .GET, pathPattern: "/newsfeed", keyPath: nil, statusCodes: nil)
        
        RKObjectManager.sharedManager().addResponseDescriptor(newsfeedDescriptor)
    }
}
