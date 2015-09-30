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
    class var sharedInstance : URLSchemesController {
        struct Static {
            static let instance : URLSchemesController = URLSchemesController()
        }
        return Static.instance
    }
    
    private init() {
        
    }
    
    func handleOpenURL(url:NSURL)->Bool {
        
        if WXApi.handleOpenURL(url, delegate: OpenidController.instance) {
            return true
        } else if let rootvc = UIApplication.sharedApplication().keyWindow?.rootViewController as? TabBarController {
            self.tabBarController = rootvc
            if let host = url.host, id = url.path, event = ListenerEvent(rawValue: host) {
                let id =  id.stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                switch event {
                case .Message:
                    openMessage(id)
                case .GroupMessage:
                    openGroupMessage(id)
                case .FriendInvited, .FriendAccepted, .FriendRefused, .FriendBreak:
                    openProfile(id)
                case .PostNew, .PostLiked, .PostCommented, .PostBookmarked:
                    openPost(id)
                default:
                    println(url) // TODO
                    return false
                }
                return true
            }
        } else {
            self.taskURL = url
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
}

// MARK -- OpenURL

extension URLSchemesController{
    
    private func openMessage(id: String){
        
        AlamofireController.request(.GET, "/users/\(id)", success: { result in
            let vc = MessageViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.friend = UserEntity(result)
            
            self.pushViewController(1, viewController: vc, animated: true)
            
            }) { err in
                
        }
    }
    
    private func openGroupMessage(id: String){
        
        AlamofireController.request(.GET, "/groups/\(id)", success: { result in
            let vc = GroupChatViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.group = GroupEntity(result)
            
            self.pushViewController(2, viewController: vc, animated: true)
            
            }) { err in
                
        }
    }
    
    private func openProfile(id: String){
        
        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = UserEntity()
        vc.user.id = id
        
        self.pushViewController(1, viewController: vc, animated: true)
    }
    
    private func openPost(id: String){
        
        AlamofireController.request(.GET, "/posts/\(id)", success: { result in
            let vc = Util.createViewControllerWithIdentifier("PostView", storyboardName: "Home") as! PostViewController
            vc.post = PostEntity(result)
            
            self.pushViewController(0, viewController: vc, animated: true)
        }) { err in
            
        }
        
    }
    
}