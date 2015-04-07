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
        
        addResponseDescriptor()
        
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
    }
}
// MARK: - Action
extension ApiController {
    
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
        #if AutoLogin
            var email = "zhangzhihua.dev@gmail.com"
            var password = "12345678"
        #endif
        
        RKObjectManager.sharedManager().postObject(nil, path: "/login", parameters: ["email" : email, "password" : password], success: { (_, result) -> Void in
            
            //no email in db
            Defaults["myId"] = (result.firstObject() as User).id
            
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
}

// MARK: - Post
extension ApiController {

    class func getNewsfeed(done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().getObjectsAtPath("/newsfeed", parameters: nil, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    //ユーザの投稿一覧
    class func getUserPosts(id: String, done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().getObjectsAtPath("/users/\(id)/posts", parameters: nil, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    class func addPost(imageNames: [String], sizes: [CGSize], content: String, done: (NSError?) -> Void) {
        var param = Dictionary<String, String>()
        param["content"] = content
        
        for i in 0..<imageNames.count {
            param["images[\(i)][name]"] = imageNames[i]
            param["images[\(i)][size][width]"] = "\(sizes[i].width)"
            param["images[\(i)][size][height]"] = "\(sizes[i].height)"
        }
        
        createPosts(param, done: done)
    }
    
    //記事の投稿
    class func createPosts(param: NSDictionary, done: (NSError?) -> Void) {
        /*
        var param = Dictionary<String, String>();
        param["content"] = "記事コンテンツ";
        for i in 1...3{
        param["images[\(i)][name]"] = "upload_2f0a4f9bfee51eacdc38f339d42eba21";
        param["images[\(i)][size][width]"] = "100";
        param["images[\(i)][size][height]"] = "100";
        }
        
        */
        RKObjectManager.sharedManager().postObject(nil, path: "/mobile/posts", parameters: param, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
}

// MARK: - ユーザ情報
extension ApiController {
    // 友達一覧
    class func getFriends(done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().getObjectsAtPath("/connections/friends", parameters: nil, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
}

// MARK: - Descriptor
extension ApiController {
    private class func addCommonResponseDescriptor(mapping:RKEntityMapping,method:RKRequestMethod,pathPattern:String?,keyPath:String?,statusCodes:NSIndexSet?) {
        let descriptor = RKResponseDescriptor(mapping: mapping, method: method, pathPattern: pathPattern, keyPath: keyPath, statusCodes: statusCodes)
        RKObjectManager.sharedManager().addResponseDescriptor(descriptor)
    }
    private class func addResponseDescriptor() {
        let usermapping = getUserMapping()
        //login
        addCommonResponseDescriptor(usermapping, method: .POST, pathPattern: "/login", keyPath: nil, statusCodes: nil)
        //UserInfo
        addCommonResponseDescriptor(usermapping, method: .GET, pathPattern: "/users/:id", keyPath: nil, statusCodes: nil)
        //newsfeed
        addCommonResponseDescriptor(getPostMapping(false), method: .GET, pathPattern: "/newsfeed", keyPath: nil, statusCodes: nil)
        //ユーザの投稿一覧
        addCommonResponseDescriptor(getPostMapping(true), method: .GET, pathPattern: "/users/:id/posts", keyPath: nil, statusCodes: nil)
        //記事の投稿
        addCommonResponseDescriptor(getPostMapping(false), method: .POST, pathPattern: "/mobile/posts", keyPath: nil, statusCodes: nil)
        //messages
        addCommonResponseDescriptor(getMessageMapping(), method: .GET, pathPattern: "/messages", keyPath: nil, statusCodes: nil)
        //友達一覧
        addCommonResponseDescriptor(usermapping, method: .GET, pathPattern: "/connections/friends", keyPath: nil, statusCodes: nil)
    }
}
// MARK: - mapping
extension ApiController {
    //common
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
    //user
    private class func getUserMapping()->RKEntityMapping{
        var mapping = _userMapping
        mapping.addPropertyMappingById("User",fromKey: "friends",toKeyPath: "friends")
        mapping.addPropertyMappingById("Group",fromKey: "groups",toKeyPath: "groups")
        mapping.addPropertyMappingById("Post",fromKey: "posts",toKeyPath: "posts")
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "devices", toKeyPath: "devices", withMapping: _devicesMapping))
        
        return mapping
    }
    //post
    private class func getPostMapping(isusers:Bool)->RKEntityMapping{
        var mapping = _postMapping
        mapping.addPropertyMappingById("User",fromKey: "bookmarked",toKeyPath: "bookmarked")
        mapping.addPropertyMappingById("User",fromKey: "liked",toKeyPath: "liked")
        if isusers {
            mapping.addPropertyMappingById("User",fromKey: "_owner",toKeyPath: "owner")
        }else{
            mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "_owner", toKeyPath: "owner", withMapping: _userMapping))
        }
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "comments", toKeyPath: "comments", withMapping: _commentsMapping))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "images_mobile", toKeyPath: "imagesmobile", withMapping: _imagesMapping))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "group", toKeyPath: "group", withMapping: _groupMapping))
        
        return mapping
    }
    //message
    private class func getMessageMapping()->RKEntityMapping{
        var mapping = _messageMapping
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "_from", toKeyPath: "from", withMapping: _userMapping))
        return mapping
    }    
}


// MARK: - mapping from plist
extension ApiController {
    private class var _postMapping: RKEntityMapping {
        return ApiController.getMapping("Post", identification: nil,pListName: nil)
    }
    private class var _imagesMapping: RKEntityMapping {
        return ApiController.getMapping("Images", identification: nil,pListName: nil)
    }
    private class var _groupMapping: RKEntityMapping {
        return ApiController.getMapping("Group", identification: nil,pListName: nil)
    }
    private class var _messageMapping: RKEntityMapping {
        return ApiController.getMapping("Message", identification: nil,pListName: nil)
    }
    private class var _userMapping: RKEntityMapping {
        return ApiController.getMapping("User", identification: nil,pListName: nil)
    }
    private class var _devicesMapping: RKEntityMapping {
        return ApiController.getMapping("Devices", identification: nil,pListName: nil)
    }
    private class var _commentsMapping: RKEntityMapping {
        var mapping = ApiController.getMapping("Comments", identification: nil,pListName: nil)
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "_owner", toKeyPath: "owner", withMapping: _userMapping))
        mapping.addPropertyMappingById("User",fromKey: "liked",toKeyPath: "liked")
        //mapping.addPropertyMappingById("User",fromKey: "_owner",toKeyPath: "owner")
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
