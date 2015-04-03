//
//  ApiController.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/26.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

private let store = RKObjectManager.sharedManager().managedObjectStore

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
        
        addMessageResponseDescriptor()
        
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
        var email = "zhangzhihua.dev@gmail.com"
        var password = "12345678"
        
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
    
    class func getMessage(done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().getObjectsAtPath("/messages", parameters: nil, success: { (_, _) -> Void in
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
        
        let userMapping = getMapping("User", identification: nil,pListName: nil)
        
        let userDescriptor = RKResponseDescriptor(mapping: userMapping, method: .POST, pathPattern: "/login", keyPath: nil, statusCodes: nil)
        
        RKObjectManager.sharedManager().addResponseDescriptor(userDescriptor)
    }
    
    class func addUserInfoResponseDescriptor() {
        let userMapping = getMapping("User", identification: nil,pListName: nil)
//        let postMapping = getMapping("Post", identification: nil,pListName: nil)
        
        userMapping.addPropertyMappingById("User",fromKey: "friends",toKeyPath: "friends")
        userMapping.addPropertyMappingById("Post",fromKey: "posts",toKeyPath: "posts")
        
        
        let userInfoDescriptor = RKResponseDescriptor(mapping: userMapping, method: .GET, pathPattern: "/users/:id", keyPath: nil, statusCodes: nil)
        
        RKObjectManager.sharedManager().addResponseDescriptor(userInfoDescriptor)
    }
    
    class func addNewsfeedResponseDescriptor() {
        let newsfeedMapping = getMapping("Post", identification: nil,pListName: nil)
        let imagesMapping = getMapping("Images", identification: nil,pListName: nil)
        let userMapping = getMapping("User", identification: nil,pListName: nil)
        
        newsfeedMapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "_owner", toKeyPath: "owner", withMapping: userMapping))
        newsfeedMapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "images_mobile", toKeyPath: "imagesmobile", withMapping: imagesMapping))
        
        let newsfeedDescriptor = RKResponseDescriptor(mapping: newsfeedMapping, method: .GET, pathPattern: "/newsfeed", keyPath: nil, statusCodes: nil)
        
        RKObjectManager.sharedManager().addResponseDescriptor(newsfeedDescriptor)
    }
    
    class func addMessageResponseDescriptor() {
        let messageMapping = getMapping("Message", identification: nil,pListName:nil)
        let userMapping = getMapping("User", identification: nil,pListName: nil)
        
        messageMapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "_from", toKeyPath: "from", withMapping: userMapping))
        
        let messageDescriptor = RKResponseDescriptor(mapping: messageMapping, method: .GET, pathPattern: "/messages", keyPath: nil, statusCodes: nil)
        
        RKObjectManager.sharedManager().addResponseDescriptor(messageDescriptor)
    }
    
    private class func getMapping(entityName:String,identification:[String]?,pListName:String?)->RKEntityMapping{
        let mapping = RKEntityMapping(forEntityForName: entityName, inManagedObjectStore: store)
        
        if let id = identification {
            mapping.identificationAttributes = id
        }else{
            mapping.identificationAttributes = ["id"]
        }
        
        var plistname = entityName + "Mapping"
        if let name = pListName {
            plistname = name
        }
        let path = NSBundle.mainBundle().pathForResource(plistname, ofType: "plist")
        let Plist = NSDictionary(contentsOfFile: path!)!
        mapping.addAttributeMappingsFromDictionary(Plist)
        return mapping
    }
}
extension RKEntityMapping{
    func addPropertyMappingById(entityName:String,fromKey:String,toKeyPath:String){
        let mapping = RKEntityMapping(forEntityForName: entityName, inManagedObjectStore: store)
        mapping.addPropertyMapping(RKAttributeMapping(fromKeyPath: nil, toKeyPath: "id"))
        let propertyMapping = RKRelationshipMapping(fromKeyPath: fromKey, toKeyPath: toKeyPath, withMapping: mapping)
        self.addPropertyMapping(propertyMapping)
    }
}
