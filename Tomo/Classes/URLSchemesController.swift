//
//  URLSchemesController.swift
//  Tomo
//
//  Created by starboychina on 2015/08/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

class URLSchemesController {
    
    var tabBarController: TabBarController!
    
    // static initialize
    class var instance : URLSchemesController {
        struct Static {
            static let instance : URLSchemesController = URLSchemesController()
        }
        return Static.instance
    }
    
    private init() {
        
    }
    
    // RemotePush
    func handleOpenURLForRemotePush(userInfo: [NSObject : AnyObject])->Bool{
        let json = JSON(userInfo)
        let type = json["type"].stringValue
        let id = json["id"].stringValue
        NSURL(string:"tomo://\(type)/\(id)")
        
        return handleOpenURL(NSURL(string:"tomo://\(type)/\(id)")!)
    }
    
    // application(application: , handleOpenURL:)
    func handleOpenURL(url:NSURL)->Bool{
        
        if WXApi.handleOpenURL(url, delegate: OpenidController.instance) {
            return true
        } else if url.scheme == "tomo" {
            
            if let rootvc = UIApplication.sharedApplication().keyWindow?.rootViewController as? TabBarController{
                self.tabBarController = rootvc
                if let host = url.host, id = url.path, event = SocketEvent(rawValue: host) {
                    let id =  id.stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    switch event {
                    case .Message:
                        receiveMessage(id)
                    case .FriendInvited:
                        receiveFriendInvited(id)
                    case .FriendApproved:
                        receiveFriendApproved(id)
                    case .PostNew:
                        receivePostNew(id)
                    case .PostCommented:
                        receivePostCommented(id)
                    default:
                        println(url) // TODO
                    }
                }
            } else {
                // TODO -> add to task
            }
        }
        return false
    }
}

extension URLSchemesController{

    private func pushViewController(tabSelectedIndex: Int, viewController: UIViewController, animated: Bool){
        
        if self.tabBarController.childViewControllers.count > tabSelectedIndex {
            self.tabBarController.selectedIndex = tabSelectedIndex
//            self.tabBarController.selectedViewController
            self.tabBarController.childViewControllers[tabSelectedIndex].pushViewController(viewController, animated: true)
        } else {
//            println( self.tabBarController.childViewControllers )
        }
        
    }
    
    private func getInformation(uri: String, done: (JSON)->() ){
        
        Util.showHUD()
        Manager.sharedInstance.request(.GET, kAPIBaseURLString + uri).responseJSON { (_, _, result, error) -> Void in
            if error == nil {
                done(JSON(result!))
            }
            Util.dismissHUD()
            
        }
    }
}

extension URLSchemesController{
    
    private func receiveMessage(id: String){
        
        getInformation("/users/\(id)", done: { (json) -> () in
            let vc = MessageViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.friend = UserEntity()
            vc.friend.id = json["_id"].string
            vc.friend.nickName = json["nickName"].string
            vc.friend.photo = json["photo_ref"].string
            
            self.pushViewController(1, viewController: vc, animated: true)
        })
    }
    
    private func receiveFriendInvited(id: String){
        
        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = UserEntity()
        vc.user.id = id
        
        self.pushViewController(1, viewController: vc, animated: true)
    }
    
    private func receiveFriendApproved(id: String){
        getInformation("/users/\(id)", done: { (json) -> () in
            
            let nickName = json["nickName"].stringValue
            Util.showInfo("\(nickName)已成为您的好友")
        })
    }
    
    private func receivePostNew(id: String){
        
        getInformation("/posts/\(id)", done: { (json) -> () in
            
            var post = PostEntity()
            post.id = json["_id"].stringValue
            post.content = json["contentText"].stringValue
            post.like = json["like"].arrayObject as? [String]
            post.coordinate = json["coordinate"].arrayObject as? [Double]
            post.createDate = json["createDate"].stringValue.toDate(format: "yyyy-MM-dd't'HH:mm:ss.SSSZ")
            
            json["images_mobile"].array?.map { (image) -> () in
                post.images = post.images ?? [String]()
                post.images?.append(image["name"].stringValue)
            }
            
            let postOwner = json["_owner"]
            post.owner = UserEntity()
            post.owner.id = postOwner["_id"].stringValue
            post.owner.nickName = postOwner["nickName"].stringValue
            post.owner.photo = postOwner["photo_ref"].string

            post.comments = []
            let postComments = json["comments"].array
            json["comments"].array?.map { (commentJson) -> () in
                
                var comment = CommentEntity()
                comment.id = commentJson["_id"].stringValue
                comment.content = commentJson["content"].stringValue
                comment.createDate = commentJson["createDate"].stringValue.toDate(format: "yyyy-MM-dd't'HH:mm:ss.SSSZ")
                
                let commentOwner = commentJson["_owner"]
                comment.owner = UserEntity()
                comment.owner.id = commentOwner["_id"].stringValue
                comment.owner.nickName = commentOwner["nickName"].stringValue
                comment.owner.photo = commentOwner["photo_ref"].string
                post.comments?.append(comment)
            }
            
            let vc = Util.createViewControllerWithIdentifier("PostView", storyboardName: "Home") as! PostViewController
            vc.post = post
            
            self.pushViewController(0, viewController: vc, animated: true)
            
        })
        
    }
    
    private func receivePostCommented(id: String){
        self.receivePostNew(id)
    }
    
}

