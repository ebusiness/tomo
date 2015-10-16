//
//  ProfileBaseController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ProfileBaseController: BaseTableViewController {
    
    var user:UserEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let resizeHeaderHeight:CGFloat = UIScreen.mainScreen().bounds.size.height * 0.618 + 80
        self.headerHeight = resizeHeaderHeight - 80 - 64
        self.changeHeaderView(height: resizeHeaderHeight, done: nil)
    }
    
    // MARK: - segue for profile header
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let vc = segue.destinationViewController as? ProfileHeaderViewController {
            
            vc.user = self.user
            if segue.sourceViewController is ProfileViewController {
                self.getUserInfo {
                    vc.user = self.user
                }
            }
            
            self.whenShowNavigationBar = { (OffsetY)->() in
                self.setNavigationBarBackgroundImage(vc.coverImageView.image)
            }
            
            let maxHeight: CGFloat = 100
            let speed: CGFloat = 0.5 * maxHeight / (UIScreen.mainScreen().bounds.size.height * 0.618 - 64) //{ return 0.5 * maxHeight / self.headerHeight }
            var photoImageViewConstraints: Dictionary<NSLayoutAttribute, NSLayoutConstraint>?
            
            self.whenHideNavigationBar = { (OffsetY)->() in
                
                if let photoImageView = vc.photoImageView where photoImageViewConstraints == nil {
                    photoImageViewConstraints = self.getConstraint(photoImageView)
                }
                
                var constant = OffsetY * speed
                if constant > 40 { constant = 40 }
                else if constant < 0 { constant = 0 }
                
                photoImageViewConstraints?[.CenterY]?.constant = constant
                
                var wh = maxHeight - constant
                if wh > maxHeight { wh = maxHeight }
                //                else if wh < 60 { wh = 60 }
                photoImageViewConstraints?[.Width]?.constant = wh
                photoImageViewConstraints?[.Height]?.constant = wh
                
                vc.photoImageView.layer.cornerRadius = wh / 2
                
//                let alpha = OffsetY / self.headerHeight
                self.setNavigationBarBackgroundImage(nil)
            }
        } else if let vc = segue.destinationViewController as? ProfileBaseController {
            vc.user = self.user
        }
    }
}

extension ProfileBaseController {
    
    func getUserInfo(done: ()->() ){
        
        AlamofireController.request(.GET, "/users/\(self.user.id)", success: { result in

            self.user = UserEntity(result)
            
            self.updateFriendInfoIfNeeded()
            
            done()
            
            self.updateUI()
        })
    }
    
    private func updateFriendInfoIfNeeded(){
        
        if !(me.friends ?? []).contains(self.user.id) {
            return
        }
        
        (self.navigationController?.tabBarController?.childViewControllers ?? []).each { (index, childViewController) -> () in

            let viewControllers = (childViewController as? UINavigationController)?.viewControllers
            
            if viewControllers == nil { return }
            
            if let friendListViewController = viewControllers!.first as? FriendListViewController {
                let index = friendListViewController.friends.indexOf { $0.id == self.user.id }
                
                if let index = index {
                    self.user.lastMessage = friendListViewController.friends[index].lastMessage
                    friendListViewController.friends[index] = self.user
                    friendListViewController.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)], withRowAnimation: .None)
                }
            }
            
            let messageViewController = viewControllers!.find { $0 is MessageViewController } as? MessageViewController
            
            if let messageViewController = messageViewController where messageViewController.friend.id == self.user.id {
                self.user.lastMessage = messageViewController.friend.lastMessage
                messageViewController.friend = self.user
            }
        }
    }
    
    func updateUI() {
        Util.dismissHUD()
    }
    
    private func getConstraint(photoImageView: UIView) -> Dictionary<NSLayoutAttribute, NSLayoutConstraint>? {
        var constraints = Dictionary<NSLayoutAttribute, NSLayoutConstraint>()
        constraints[.Width] = photoImageView.constraints().find { $0.firstAttribute == .Width } as? NSLayoutConstraint
        constraints[.Height] = photoImageView.constraints().find { $0.firstAttribute == .Height } as? NSLayoutConstraint
        constraints[.CenterY] = photoImageView.superview?.constraints().find { $0.firstAttribute == .CenterY } as? NSLayoutConstraint
        return constraints
    }
}