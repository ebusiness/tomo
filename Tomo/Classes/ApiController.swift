//
//  ApiController.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/26.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

enum GroupType: String {
    case Public = "public"
    
    func str() -> String {
        switch self {
        case Public:
            return "一般公開"
        }
    }
}

enum GroupSection: Int {
    case Unknown, MyGroup, Discover
    
    func groupSectionTitle() -> String {
        switch self {
        case Unknown:
            return "無し"
        case MyGroup:
            return "参加中のグループ"
        case Discover:
            return "おすすめのグループ"
        }
    }
}

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
        
        NSPersistentStoreCoordinator.MR_setDefaultStoreCoordinator(store.persistentStoreCoordinator)
        NSManagedObjectContext.MR_setRootSavingContext(store.persistentStoreManagedObjectContext)
        NSManagedObjectContext.MR_setDefaultContext(store.mainQueueManagedObjectContext)
        
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
            Defaults["myId"] = (result.firstObject as! User).id
            
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
    
    class func dicFromPlist(name: String) -> NSDictionary {
        let path = NSBundle.mainBundle().pathForResource(name, ofType: "plist")
        return NSDictionary(contentsOfFile: path!)!
    }
}

// MARK: - Post
extension ApiController {

    class func getNewsfeed(user: User? = nil, done: (NSError?) -> Void) {
        if let user = user {
            getUserPosts(user.id!, done: done)
            return
        }
        
        RKObjectManager.sharedManager().getObjectsAtPath("/newsfeed", parameters: nil, success: { (_, _) -> Void in
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
        RKObjectManager.sharedManager().postObject(nil, path: "/mobile/posts", parameters: param as [NSObject : AnyObject], success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    //記事ー＞いいね 登録・解除
    class func postLike(id: String, done: (NSError?) -> Void) {
        
        RKObjectManager.sharedManager().patchObject(nil, path: "/posts/\(id)/like", parameters: nil, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    //記事ー＞bookmark 登録・解除
    class func postBookmark(id: String, done: (NSError?) -> Void) {
        
        RKObjectManager.sharedManager().patchObject(nil, path: "/posts/\(id)/bookmark", parameters: nil, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    //記事ー＞編集
    class func postEdit(id: String,content:String, done: (NSError?) -> Void) {
        var param = Dictionary<String, String>();
        param["content"] = content;
        
        RKObjectManager.sharedManager().patchObject(nil, path: "/posts/\(id)", parameters: param, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    //記事ー＞コメント禁止・許可
    class func postCommentable(id: String,commentable:Bool, done: (NSError?) -> Void) {
        var param = Dictionary<String, AnyObject >();
        param["setting.commentable"] = commentable;
        
        RKObjectManager.sharedManager().patchObject(nil, path: "/posts/\(id)", parameters: param, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    //記事ー＞削除
    class func postDelete(id: String, done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().deleteObject(nil, path: "/posts/\(id)", parameters: nil, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    class func addComment(id: String,content: String, done: (NSError?) -> Void) {
        var param = Dictionary<String, String>()
        param["content"] = content
        
        createComment(id, param: param) { (error) -> Void in
            done(error)
        }
    }
    
    //記事のコメント
    class func createComment(id: String,param: NSDictionary, done: (NSError?) -> Void) {
        /*
        var param = Dictionary<String, String>();
        param["content"] = "記事コンテンツ";
        param["replyTo"] = "552220aa915a1dd84834731b";//コメントID
        */
        RKObjectManager.sharedManager().postObject(nil, path: "/posts/\(id)/comments", parameters: param as [NSObject : AnyObject], success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    //記事のコメントー＞編集
    class func commentEdit(id: String,cid: String,content:String, done: (NSError?) -> Void) {
        var param = Dictionary<String, String>();
        param["content"] = content;
        
        RKObjectManager.sharedManager().patchObject(nil, path: "/posts/\(id)/comments/\(cid)", parameters: param, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    //記事のコメントー＞削除
    class func commentDelete(id: String,cid: String, done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().deleteObject(nil, path: "/posts/\(id)/comments/\(cid)", parameters: nil, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    class func getPost(id: String, done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().getObjectsAtPath("/posts/\(id)", parameters: nil, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
}

// MARK: - ユーザ情報
extension ApiController {
    //ユーザの投稿一覧
    class func getUserPosts(id: String, done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().getObjectsAtPath("/users/\(id)/posts", parameters: nil, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    // 友達一覧
    class func getFriends(done: (NSError?) -> Void) {
        //取得情报
        RKObjectManager.sharedManager().getObjectsAtPath("/connections/friends", parameters: nil, success: { (_, _) -> Void in
//            done(nil)
            
            //建立关联
            self.getUserInfo(Defaults["myId"].string!, done: { (error) -> Void in
                done(error)
            })
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    //陌生人一览
    class func getUsers(done: (NSError?) -> Void) {
        //取得情报
        RKObjectManager.sharedManager().getObjectsAtPath("/connections/discover", parameters: nil, success: { (_, _) -> Void in
                        done(nil)
            
//            //建立关联
//            self.getUserInfo(Defaults["myId"].string!, done: { (error) -> Void in
//                done(error)
//            })
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    class func getUsers(#key: String, value: String, done: ([User]?, NSError?) -> Void) {
        var param = Dictionary<String, String>()
        param[key] = value
        
        RKObjectManager.sharedManager().getObjectsAtPath("/mobile/stations/users", parameters: param, success: { (_, results) -> Void in
            done((results.array() as? [User]), nil)
            }) { (_, error) -> Void in
                done(nil, error)
        }
    }
    
    // token uuid の登録・編集
    class func setDeviceInfo(token:String,done: (NSError?) -> Void) {
        
        
        
        var param = Dictionary<String, String>();
        param["name"] = UIDevice.currentDevice().name
        param["uuid"] = UIDevice.currentDevice().identifierForVendor.UUIDString; 
        if "" != token {//"" の場合,変更しない
            param["token"] = token
        }
        
        RKObjectManager.sharedManager().postObject(nil, path: "/mobile/user/device", parameters: param, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
        
        
    }
    
    class func invite(id: String, done: (NSError?) -> Void) {
        var param = Dictionary<String, String>()
        param["id"] = id
        
        RKObjectManager.sharedManager().patchObject(nil,path:"/connections/invite", parameters: param, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    class func editAvatarName(name: String, done: (NSError?) -> Void) {
        var param = Dictionary<String, String>()
        param["photo"] = name
        
        let id = Defaults["myId"].string!
        
        RKObjectManager.sharedManager().patchObject(nil,path:"/users/\(id)", parameters: param, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }

    class func editUser(user: User, done: (NSError?) -> Void) {
        var param = Dictionary<String, String>()
        param["address"] = user.address
        param["nearestSt"] = user.nearestSt
        param["webSite"] = user.webSite
        param["bioText"] = user.bioText
        param["telNo"] = user.telNo
        param["firstName"] = user.firstName
        param["lastName"] = user.lastName
        param["birthDay"] = user.birthDay?.toString(format: DateFormat.Custom("yyyy/MM/dd"))
        param["gender"] = user.gender
        
        let id = user.id!

        RKObjectManager.sharedManager().patchObject(nil,path:"/users/\(id)", parameters: param, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
//        param["address"] = user.address
    }
//    class func editUserInfo(key: String, value: String, done: (NSError?) -> Void) {
//        var param = Dictionary<String, String>()
//        param["key"] = value
//        
//        let id = Defaults["myId"].string!
//        
//        RKObjectManager.sharedManager().patchObject(nil,path:"/users/\(id)", parameters: param, success: { (_, _) -> Void in
//            done(nil)
//            }) { (_, error) -> Void in
//                done(error)
//        }
//    }
}

// MARK: - Group

extension ApiController {
    
    class func getGroups(done: (NSError?) -> Void) {
        getGroupsJoined { (error) -> Void in
            self.getGroupsDiscover({ (error) -> Void in
                done(error)
            })
        }
        
//        RKObjectManager.sharedManager().getObjectsAtPath("/mobile/group", parameters: nil, success: { (_, result) -> Void in
//            done(nil)
//            }) { (_, error) -> Void in
//                done(error)
//        }
    }
    
    class func getGroupsJoined(done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().getObjectsAtPath("/groups/joined", parameters: nil, success: { (_, result) -> Void in
            if let result = result {
                for group in (result.array() as! [Group]) {
                    group.section = GroupSection.MyGroup.rawValue
                }
                
                DBController.save(done: { () -> Void in
                    done(nil)
                })
            } else {
                done(nil)
            }
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    class func getGroupsDiscover(done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().getObjectsAtPath("/groups/discover", parameters: nil, success: { (_, result) -> Void in
            if let result = result {
                for group in (result.array() as! [Group]) {
                    group.section = GroupSection.Discover.rawValue
                }
                
                DBController.save(done: { () -> Void in
                    done(nil)
                })
            } else {
                done(nil)
            }
            
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    class func createGroup(title: String, content: String?, type: GroupType = .Public, localImagePath: String?, done: (String?, NSError?) -> Void) {
        var param = Dictionary<String, String>()
        param["name"] = title
        param["description"] = content
        param["type"] = type.rawValue
        
        RKObjectManager.sharedManager().postObject(nil, path: "/groups", parameters: param as [NSObject : AnyObject], success: { (_, mappingResult) -> Void in
            if let group = mappingResult.firstObject as? Group {
                group.section = GroupSection.MyGroup.rawValue
                DBController.save(done: { () -> Void in
                    done(group.id, nil)
                })
            } else {
                done(nil, nil)
            }
            
            }) { (_, error) -> Void in
                done(nil, error)
        }
    }

    class func editGroup(#groupId: String, key: String, value: String, done: (NSError?) -> Void) {
        var param = Dictionary<String, String>()
        param[key] = value
        
        // TODO: type, image
        
        RKObjectManager.sharedManager().patchObject(nil, path: "/groups/\(groupId)", parameters: param as [NSObject : AnyObject], success: { (_, mappingResult) -> Void in
            if let group = mappingResult.firstObject as? Group {
                group.section = GroupSection.MyGroup.rawValue
                DBController.save(done: { () -> Void in
                    done(nil)
                })
            } else {
                done(nil)
            }
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    class func editGroup(#groupId: String, param: Dictionary<String, String>, done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().patchObject(nil, path: "/groups/\(groupId)", parameters: param as [NSObject : AnyObject], success: { (_, mappingResult) -> Void in
            if let group = mappingResult.firstObject as? Group {
                group.section = GroupSection.MyGroup.rawValue
                DBController.save(done: { () -> Void in
                    done(nil)
                })
            } else {
                done(nil)
            }
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    class func changeGroupCover(localImagePath: String, groupId: String, done: (NSError?) -> Void) {
        let fileName = localImagePath.lastPathComponent

        let remotePath = Constants.groupCoverPath(groupId: groupId, fileName: fileName)
        
        S3Controller.uploadFile(name: fileName, localPath: localImagePath, remotePath: remotePath, done: { (error) -> Void in
            if error == nil {
                self.editGroup(groupId: groupId, key: "cover", value: fileName, done: { (error) -> Void in
                    
                })
            }
        })
    }
    
    class func joinGroup(groupId: String, done: (NSError?) -> Void) {
        var param = Dictionary<String, String>()
        
        RKObjectManager.sharedManager().patchObject(nil, path: "/groups/\(groupId)/join", parameters: param as [NSObject : AnyObject], success: { (_, mappingResult) -> Void in
            if let group = mappingResult.firstObject as? Group {
                group.section = GroupSection.MyGroup.rawValue
                DBController.save(done: { () -> Void in
                    done(nil)
                })
            } else {
                done(nil)
            }
            }) { (_, error) -> Void in
                done(error)
        }
    }
}

// MARK: - Station

extension ApiController {
    
    class func getStations(done: (NSError?) -> Void) {
        var param = Dictionary<String, String>()
        param["name"] = "JR山手線"
        
        RKObjectManager.sharedManager().getObjectsAtPath("/mobile/stations", parameters: param, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
}

// MARK: - Message

extension ApiController {
    
    class func sendMessage(to: [String], subject: String? = "no subject", content: String) {
        var param = NSMutableDictionary.new()
        
        for i in 0..<to.count {
            param["recipient[\(i)]"] = to[i]
        }
        
        param["subject"] = subject
        param["content"] = content

//        let myId = DBController.myUser().id!
        RKObjectManager.sharedManager().postObject(nil, path: "/messages", parameters: param as [NSObject : AnyObject], success: { (_, _) -> Void in
            }) { (_, error) -> Void in
//                done(error)
        }
    }
    
    class func getMessage(done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().getObjectsAtPath("/messages", parameters: nil, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    class func getMessageUnread(done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().getObjectsAtPath("/messages/unread", parameters: nil, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    class func getMessageSent(done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().getObjectsAtPath("/messages/sent", parameters: nil, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    class func readMessage(id :String,done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().patchObject(nil,path:"/messages/\(id)", parameters: nil, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    
}

// MARK: - Notification

extension ApiController {
    
    class func unconfirmedNotification(done: (NSError?) -> Void) {
        RKObjectManager.sharedManager().getObjectsAtPath("/notifications/unconfirmed", parameters: nil, success: { (_, _) -> Void in
            done(nil)
            }) { (_, error) -> Void in
                done(error)
        }
    }
    
    class func approveFriendInvite(id: String, done: (NSError?) -> Void) {
        var param = Dictionary<String, String>()
        param["result"] = "approved"
        
        RKObjectManager.sharedManager().patchObject(nil,path:"/notifications/\(id)", parameters: param, success: { (_, _) -> Void in
//            done(nil)
            self.getUserInfo(Defaults["myId"].string!, done: { (error) -> Void in
                done(error)
            })
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
        let msgmapping = getMessageMapping(true)
        //login
        addCommonResponseDescriptor(usermapping, method: .POST, pathPattern: "/login", keyPath: nil, statusCodes: nil)
        //UserInfo
        addCommonResponseDescriptor(usermapping, method: .GET, pathPattern: "/users/:id", keyPath: nil, statusCodes: nil)
        addCommonResponseDescriptor(usermapping, method: .PATCH, pathPattern: "/users/:id", keyPath: nil, statusCodes: nil)
        //newsfeed
        addCommonResponseDescriptor(getPostMapping(false), method: .GET, pathPattern: "/newsfeed", keyPath: nil, statusCodes: nil)
        //ユーザの投稿一覧
        addCommonResponseDescriptor(getPostMapping(true), method: .GET, pathPattern: "/users/:id/posts", keyPath: nil, statusCodes: nil)
        //記事の投稿
        addCommonResponseDescriptor(getPostMapping(false), method: .POST, pathPattern: "/mobile/posts", keyPath: nil, statusCodes: nil)
        //messages
        addCommonResponseDescriptor(msgmapping, method: .GET, pathPattern: "/messages", keyPath: nil, statusCodes: nil)
        //messages
        addCommonResponseDescriptor(msgmapping, method: .GET, pathPattern: "/messages/unread", keyPath: nil, statusCodes: nil)
        //messages
        addCommonResponseDescriptor(getMessageMapping(false), method: .GET, pathPattern: "/messages/sent", keyPath: nil, statusCodes: nil)
        //messages
        addCommonResponseDescriptor(msgmapping, method: .PATCH, pathPattern: "/messages/:id", keyPath: nil, statusCodes: nil)
        //messages
//        addCommonResponseDescriptor(getMessageMapping(), method: .POST, pathPattern: "/messages", keyPath: nil, statusCodes: nil)
        //友達一覧
        addCommonResponseDescriptor(usermapping, method: .GET, pathPattern: "/connections/friends", keyPath: nil, statusCodes: nil)
        //陌生人一览
        addCommonResponseDescriptor(usermapping, method: .GET, pathPattern: "/connections/discover", keyPath: nil, statusCodes: nil)
        //記事のコメント
        addCommonResponseDescriptor(getCommoentMapping(false), method: .POST, pathPattern: "/posts/:id/comments", keyPath: nil, statusCodes: nil)
        //記事ー＞いいね 登録・解除
        addCommonResponseDescriptor(getPostMapping(false), method: .PATCH, pathPattern: "/posts/:id/like", keyPath: nil, statusCodes: nil)
        //記事ー＞bookmark 登録・解除
        addCommonResponseDescriptor(getPostMapping(false), method: .PATCH, pathPattern: "/posts/:id/bookmark", keyPath: nil, statusCodes: nil)
        //記事ー＞編集  コメント禁止・許可
        addCommonResponseDescriptor(getPostMapping(false), method: .PATCH, pathPattern: "/posts/:id", keyPath: nil, statusCodes: nil)
        //記事のコメントー＞編集
        addCommonResponseDescriptor(getCommoentMapping(true), method: .PATCH, pathPattern: "/posts/:id/comments/:cid", keyPath: nil, statusCodes: nil)
        //記事のコメントー＞削除
        addCommonResponseDescriptor(getCommoentMapping(true), method: .DELETE, pathPattern: "/posts/:id/comments/:cid", keyPath: nil, statusCodes: nil)
        //記事ー＞削除
        addCommonResponseDescriptor(getPostMapping(true), method: .DELETE, pathPattern: "/posts/:id", keyPath: nil, statusCodes: nil)
        //記事ー＞詳細
        addCommonResponseDescriptor(getPostMapping(false), method: .GET, pathPattern: "/posts/:id", keyPath: nil, statusCodes: nil)
        
        //Notification
        addCommonResponseDescriptor(getNotificationMapping(false), method: .GET, pathPattern: "/notifications/unconfirmed", keyPath: nil, statusCodes: nil)
        addCommonResponseDescriptor(getNotificationMapping(true), method: .PATCH, pathPattern: "/notifications/:id", keyPath: nil, statusCodes: nil)
        addCommonResponseDescriptor(usermapping, method: .PATCH, pathPattern: "/connections/invite", keyPath: nil, statusCodes: nil)
        
        //グループ
        addCommonResponseDescriptor(getGroupMapping(false), method: .GET, pathPattern: "/groups/discover", keyPath: nil, statusCodes: nil)
        addCommonResponseDescriptor(getGroupMapping(false), method: .GET, pathPattern: "/groups/joined", keyPath: nil, statusCodes: nil)
        addCommonResponseDescriptor(getGroupMapping(false), method: .POST, pathPattern: "/groups", keyPath: nil, statusCodes: nil)
        addCommonResponseDescriptor(getGroupMapping(false), method: .PATCH, pathPattern: "/groups/:id", keyPath: nil, statusCodes: nil)
        addCommonResponseDescriptor(getGroupMapping(false), method: .PATCH, pathPattern: "/groups/:id/join", keyPath: nil, statusCodes: nil)
//        addCommonResponseDescriptor(getSectionedGroupMapping(), method: .GET, pathPattern: "/mobile/group", keyPath: nil, statusCodes: nil)
        
        //駅
        addCommonResponseDescriptor(getStationMapping(false), method: .GET, pathPattern: "/mobile/stations", keyPath: nil, statusCodes: nil)
        
        addCommonResponseDescriptor(getUserMapping(), method: .GET, pathPattern: "/mobile/stations/users", keyPath: nil, statusCodes: nil)
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
        mapping.addAttributeMappingsFromDictionary(Plist as [NSObject : AnyObject])
        return mapping
    }
    //user
    private class func getUserMapping()->RKEntityMapping{
        var mapping = _userMapping
        mapping.addPropertyMappingById("User",fromKey: "friends",toKeyPath: "friends")
        mapping.addPropertyMappingById("User",fromKey: "invited",toKeyPath: "invited")
        mapping.addPropertyMappingById("Group",fromKey: "groups",toKeyPath: "groups")
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "mygroup", toKeyPath: "mygroup", withMapping: _groupMapping))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "discover", toKeyPath: "discover", withMapping: _groupMapping))
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
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "comments", toKeyPath: "comments", withMapping: getCommoentMapping(false)))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "images_mobile", toKeyPath: "imagesmobile", withMapping: _imagesMapping))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "group", toKeyPath: "group", withMapping: _groupMapping))
        
        return mapping
    }
    //message
    private class func getMessageMapping(isrecipientidonly:Bool)->RKEntityMapping{
        var mapping = _messageMapping
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "_from", toKeyPath: "from", withMapping: _userMapping))
        
        if(isrecipientidonly){
            mapping.addPropertyMappingById("User",fromKey: "_recipient",toKeyPath: "to")
        }else{
            mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "_recipient", toKeyPath: "to", withMapping: _userMapping))
        }
        return mapping
    }
    //comment
    private class func getCommoentMapping(isidonly:Bool)->RKEntityMapping{
        var mapping = _commentsMapping
        if(isidonly){
            mapping.addPropertyMappingById("User",fromKey: "_owner",toKeyPath: "owner")
        }else{
            mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "_owner", toKeyPath: "owner", withMapping: _userMapping))
        }
        mapping.addPropertyMappingById("User",fromKey: "liked",toKeyPath: "liked")
        return mapping
    }
    
    //Notification
    private class func getNotificationMapping(isidonly:Bool)->RKEntityMapping{
        var mapping = _notificationMapping
        
        if(isidonly){
            mapping.addPropertyMappingById("User",fromKey: "_from",toKeyPath: "from")
        } else {
            mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "_from", toKeyPath: "from", withMapping: _userMapping))
        }

        mapping.addPropertyMappingById("User",fromKey: "_owner",toKeyPath: "owner")
        mapping.addPropertyMappingById("User",fromKey: "confirmed",toKeyPath: "confirmed")

        return mapping
    }
    
    //group
    private class func getGroupMapping(isidonly:Bool)->RKEntityMapping{
        var mapping = _groupMapping
        mapping.addPropertyMappingById("User",fromKey: "_owner",toKeyPath: "owner")
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "posts", toKeyPath: "posts", withMapping: _postMapping))
        mapping.addPropertyMappingById("User",fromKey: "participants",toKeyPath: "participants")
 
        return mapping
    }
    
//    private class func getSectionedGroupMapping(isidonly:Bool) -> RKEntityMapping {
//        let mapping = RKEntityMapping(forEntityForName: "Group", inManagedObjectStore: store)
//        
//        if let id = identification {
//            mapping.identificationAttributes = id
//        }else{
//            mapping.identificationAttributes = ["id"]
//        }
//        
//        var plistname = entityName + "Mapping"
//        if let name = pListName {
//            plistname = name
//        }
//        let path = NSBundle.mainBundle().pathForResource(plistname, ofType: "plist")
//        let Plist = NSDictionary(contentsOfFile: path!)!
//        mapping.addAttributeMappingsFromDictionary(Plist as [NSObject : AnyObject])
//        return mapping
//        var mapping = _groupMapping
//        mapping.addPropertyMappingById("User",fromKey: "_owner",toKeyPath: "owner")
//        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "posts", toKeyPath: "posts", withMapping: _postMapping))
//        mapping.addPropertyMappingById("User",fromKey: "participants",toKeyPath: "participants")
//        
//        return mapping
//    }
    
    //station
    private class func getStationMapping(isidonly:Bool)->RKEntityMapping{
        var mapping = _lineMapping
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "stations", toKeyPath: "stations", withMapping: _stationMapping))
        
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
        return mapping
    }
    private class var _notificationMapping: RKEntityMapping {
        var mapping = ApiController.getMapping("Notification", identification: nil,pListName: nil)
        return mapping
    }
    private class var _lineMapping: RKEntityMapping {
        var mapping = ApiController.getMapping("Line", identification: nil,pListName: nil)
        return mapping
    }
    private class var _stationMapping: RKEntityMapping {
        var mapping = ApiController.getMapping("Station", identification: nil,pListName: nil)
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
