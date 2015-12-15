//
//  URLSchemesController.swift
//  Tomo
//
//  Created by starboychina on 2015/08/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//
import WechatKit

class URLSchemesController {
    
    var tabBarController: TabBarController!
    var taskURL: NSURL?
    
    // static initialize
    static let sharedInstance : URLSchemesController = URLSchemesController()

    private init() {
        
        WechatManager.appid = "wx4079dacf73fef72d"
        WechatManager.sharedInstance.shareDelegate = self
    }
    
    func handleOpenURL(url:NSURL)->Bool {
        
        if WechatManager.sharedInstance.handleOpenURL(url) {
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
//                    println(url) // TODO
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
            if let selectedViewController = self.tabBarController.childViewControllers[tabSelectedIndex] as? UINavigationController {
                selectedViewController.popToRootViewControllerAnimated(false)
                selectedViewController.pushViewController(viewController, animated: true)
            }
        } else {
//            println( self.tabBarController.childViewControllers )
        }
    }
    
    private func refreshViewControllerIfNeeded(tabSelectedIndex: Int, key: AnyObject){
        
        if self.tabBarController.childViewControllers.count > tabSelectedIndex {
            self.tabBarController.selectedIndex = tabSelectedIndex
            let vc: AnyObject? = self.tabBarController.childViewControllers[tabSelectedIndex].childViewControllers.first
            /// mark the cell
            if let friendListViewController = vc as? FriendListViewController {
                let index = friendListViewController.friends.indexOf { $0.id == key as! String }
                if let index = index {
                    let indexPath = NSIndexPath(forItem: index, inSection: 1)
                    friendListViewController.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)//.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            }
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
            
            self.refreshViewControllerIfNeeded(1, key: vc.friend.id)
            
        })
    }
    
    private func openGroupMessage(id: String){
        
        AlamofireController.request(.GET, "/groups/\(id)", success: { result in
            let vc = GroupChatViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.group = GroupEntity(result)
            
            self.pushViewController(2, viewController: vc, animated: true)
            
        })
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
        })        
    }
    
}

extension URLSchemesController: WechatManagerShareDelegate {
    func showMessage(message: String) {
        URLSchemesController.sharedInstance.handleOpenURL(NSURL(string: "tomo://post-new/\(message)")!)
    }
}
