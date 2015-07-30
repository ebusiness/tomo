//
//  ProfileViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ProfileViewController: ProfileBaseController {

    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var birthDayLabel: UILabel!
    
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var deleteFriendButton: UIButton!
    @IBOutlet weak var sendMessageCell: UITableViewCell!
    
    @IBOutlet weak var invitedView: UIView!
    @IBOutlet weak var heightOfInvitedView: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateUI()
        
        ApiController.getUserInfo(user.id!, done: { (error) -> Void in
            if error == nil {
                self.updateUI()
            }
        })
        
    }
    
    @IBAction func Approved(sender: UIButton) {
        
        inviteAction(true)
    }
    
    @IBAction func Declined(sender: UIButton) {
        
        inviteAction(false)
    }
    
    @IBAction func deleteFriend(sender: UIButton) {
        
        Util.alert(self, title: "删除好友", message: "确定删除该好友么?", action: { (_) -> Void in
            ApiController.connectionsBreakUsers(self.user.id!, done: { (error) -> Void in
                ApiController.getMyInfo({ (error) -> Void in
                    
                    self.updateUI()
                    Util.showSuccess("已删除好友")
                })
            })
        })
        
    }
    
    @IBAction func addFriend(sender: UIButton) {
        
        Util.showHUD()
        ApiController.invite(self.user.id!, done: { (error) -> Void in
            if error == nil {
                
                self.updateUI()
                Util.showSuccess("已发送交友请求")
            }
        })
        
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        
        let vc = MessageViewController()
        vc.hidesBottomBarWhenPushed = true
        
        vc.friend = self.user
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension ProfileViewController {
    
    func updateUI() {
        
        fullNameLabel.text = user?.fullName()
        
        genderLabel.text = user?.gender
        
        //        birthDayLabel.text = user?.birthDay.
        
        addressLabel.text = user?.address
        
        self.addFriendButton.hidden = true
        self.deleteFriendButton.hidden = true
        self.sendMessageCell.hidden = true
        self.invitedView.hidden = true
        
        
        if DBController.isFriend(user) {
            
            self.deleteFriendButton.hidden = false
            self.sendMessageCell.hidden = false
            
        } else {
            
            if let id = self.getInvitedNotificationId() {
                
                self.invitedView.hidden = false
                
            } else if !DBController.isInvitedUser(user) && user.id != Defaults["myId"].string {
                
                self.addFriendButton.hidden = false
            }
            
        }

    }
    
    func getInvitedNotificationId() -> String? {
        let notifications = DBController.unconfirmedNotification(type: .FriendInvited)
        
        for notification in notifications {
            if let from = notification.from where from == user {
                return notification.id
            }
        }
        return nil
        
    }
    
    func inviteAction(isApproved:Bool){
        
        if let id = self.getInvitedNotificationId() {
            
            Util.showHUD()
            ApiController.friendInvite(id,isApproved: isApproved, done: { (error) -> Void in
                
                if isApproved {
                    Util.showSuccess("已同意添加好友")
                } else {
                    Util.showSuccess("已拒绝添加好友")
                }
                
                ApiController.unconfirmedNotification { (error) -> Void in
                    
                    self.heightOfInvitedView.constant = 0
                    
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        
                        self.tableView.tableHeaderView?.frame.size.height = 240
                        self.view.layoutIfNeeded()
                        self.updateUI()
                        
                    })
                }
            })
            
        }
        
    }
}
