//
//  URLSchemesController.swift
//  Tomo
//
//  Created by starboychina on 2015/08/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

class URLSchemesController {
    
    var tabBarController: TabBarController!
    var taskURL: NSURL?
    
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
                self.taskURL = url
            }
        }
        return false
    }
    
    func runTask()->Bool{
        if let url = self.taskURL {
            self.taskURL = nil
            return handleOpenURL(url)
        } else {
            return false
        }
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
            vc.friend = UserEntity(json)
            
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

            let vc = Util.createViewControllerWithIdentifier("PostView", storyboardName: "Home") as! PostViewController
            vc.post = PostEntity(json)
            
            self.pushViewController(0, viewController: vc, animated: true)
            
        })
        
    }
    
    private func receivePostCommented(id: String){
        self.receivePostNew(id)
    }
    
}

