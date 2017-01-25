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
    var taskURL: URL?
    
    // static initialize
    static let sharedInstance : URLSchemesController = URLSchemesController()

    private init() {
        
        WechatManager.appid = "wx4079dacf73fef72d"
        WechatManager.sharedInstance.shareDelegate = self
    }
    
    @discardableResult
    func handleOpenURL(_ url: URL)->Bool {
        
        if WechatManager.sharedInstance.handleOpenURL(url) {
            return true
        } else if let rootvc = UIApplication.shared.keyWindow?.rootViewController as? TabBarController {
            self.tabBarController = rootvc
            guard let host = url.host, let event = ListenerEvent(rawValue: host) else { return false }
            let id =  url.path.replacingOccurrences(of: "/", with: "")
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
        } else {
            self.taskURL = url
        }
        
        return false
    }
    @discardableResult
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
    
    fileprivate func pushViewController(tabSelectedIndex: Int, viewController: UIViewController, animated: Bool){
        
        if self.tabBarController.childViewControllers.count > tabSelectedIndex {
            self.tabBarController.selectedIndex = tabSelectedIndex
//            self.tabBarController.selectedViewController
            if let selectedViewController = self.tabBarController.childViewControllers[tabSelectedIndex] as? UINavigationController {
                selectedViewController.popToRootViewController(animated: false)
                selectedViewController.pushViewController(viewController, animated: true)
            }
        } else {
//            println( self.tabBarController.childViewControllers )
        }
    }
}

// MARK -- OpenURL

extension URLSchemesController{
    
    fileprivate func openMessage(_ id: String){
        
        Router.User.FindById(id: id).response {
            if $0.result.isFailure { return }
            
//            let vc = MessageViewController()
//            vc.hidesBottomBarWhenPushed = true
//            vc.friend = UserEntity($0.result.value!)
//            
//            self.pushViewController(1, viewController: vc, animated: true)
        }
    }
    
    fileprivate func openGroupMessage(_ id: String){
        
        Router.Group.FindById(id: id).response {
            if $0.result.isFailure { return }
            
//            let vc = GroupChatViewController()
//            vc.hidesBottomBarWhenPushed = true
//            vc.group = GroupEntity($0.result.value!)
//            
//            self.pushViewController(2, viewController: vc, animated: true)
        }
    }
    
    fileprivate func openProfile(_ id: String){
        
//        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
//        vc.user = UserEntity()
//        vc.user.id = id
//        
//        self.pushViewController(1, viewController: vc, animated: true)
    }
    
    fileprivate func openPost(_ id: String){
        
        Router.Post.FindById(id: id).response {
            if $0.result.isFailure { return }
//            
//            let vc = Util.createViewControllerWithIdentifier("PostDetailViewController", storyboardName: "Home") as! PostDetailViewController
//            vc.post = PostEntity($0.result.value!)
//            
//            self.pushViewController(0, viewController: vc, animated: true)
        }
    }
    
}

extension URLSchemesController: WechatManagerShareDelegate {
    func showMessage(_ message: String) {
        URLSchemesController.sharedInstance.handleOpenURL(URL(string: "tomo://post-new/\(message)")!)
    }
}
