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
    
    var invitedId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SocketController.sharedInstance.addObserverForEvent(self, selector: Selector("receiveFriendInvited:"), event: .FriendInvited)
        SocketController.sharedInstance.addObserverForEvent(self, selector: Selector("receiveFriendApproved:"), event: .FriendApproved)
        SocketController.sharedInstance.addObserverForEvent(self, selector: Selector("receiveFriendDeclined:"), event: .FriendDeclined)

    }
    
    override func updateUI() {
        super.updateUI()
        
        if let firstName = user.firstName, lastName = user.lastName {
            fullNameLabel.text = user.fullName()
        }
        
        if let gender = user.gender {
            genderLabel.text = gender
        }
        
        if let birthDay = user.birthDay {
            birthDayLabel.text = birthDay.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
        }
        
        if let address = user.address {
            addressLabel.text = address
        }
        
        self.addFriendButton.hidden = true
        self.deleteFriendButton.hidden = true
        self.sendMessageCell.hidden = true
        self.invitedView.hidden = true
        
        if let friends = me.friends where friends.contains(self.user.id) {
            
            self.deleteFriendButton.hidden = false
            self.sendMessageCell.hidden = false
            
        } else {
            
            if let id = self.invitedId {
                
                self.invitedView.hidden = false
                
                self.heightOfInvitedView.constant = 44
                self.changeHeaderView(height:284)
                
            } else if let invited = me.invited where invited.contains(self.user.id) {
                //invited
            } else if user.id != me.id {
                self.addFriendButton.hidden = false
            }
        }
    }
    
    @IBAction func Approved(sender: UIButton) {
        
        inviteAction(true)
    }
    
    @IBAction func Declined(sender: UIButton) {
        
        inviteAction(false)
    }
    
    @IBAction func deleteFriend(sender: UIButton) {
        
        Util.alert(self, title: "删除好友", message: "确定删除该好友么?", action: { (_) -> Void in
            var param = Dictionary<String, String>()
            param["id"] = self.user.id
            
            Manager.sharedInstance.request(.PATCH, kAPIBaseURLString + "/connections/break", parameters: param)
                .responseJSON { (_, _, _, error) -> Void in
                    
                    if let error = error {
                        
                    } else {
                        me.friends?.remove(self.user.id)
                        Util.showSuccess("已删除好友")
//                        self.navigationController?.popViewControllerAnimated(true)
                    }
                    self.updateUI()
            }
        })
        
    }
    
    @IBAction func addFriend(sender: UIButton) {
        
        Util.showHUD()
        
        var param = Dictionary<String, String>()
        param["id"] = self.user.id
        
        Manager.sharedInstance.request(.PATCH, kAPIBaseURLString + "/connections/invite", parameters: param)
            .responseJSON { (_, _, _, _) -> Void in
                
                if me.invited == nil {
                    me.invited = []
                }
                me.invited?.append(self.user.id)
                Util.showSuccess("已发送交友请求")
                self.updateUI()
        }
        
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        
        let vc = MessageViewController()
        vc.hidesBottomBarWhenPushed = true
        
        vc.friend = self.user
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension ProfileViewController {
    
    func inviteAction(isApproved:Bool){
        
        if let id = self.invitedId {
            
            Util.showHUD()
            var param = Dictionary<String, String>()
            param["result"] = isApproved ? "approved" : "declined"
            
            Manager.sharedInstance.request(.PATCH, kAPIBaseURLString + "/notifications/\(id)", parameters: param).response({ (_, _, _, _) -> Void in
                self.addFriendToMe(isApproved,isComeFromSocket: false)
                me.friendInvitations = me.friendInvitations.filter{ $0.from.id != self.user.id }
            })
        }
    }
    
    func addFriendToMe(isApproved:Bool,isComeFromSocket: Bool = true){
        
        if isApproved {
            
            Util.showSuccess(self.user.nickName + " 已成为您的好友")
//                me.friendInvitations = me.friendInvitations?.filter{ $0.from.id != self.user.id } //already do it in the friendlistViewController when called by NSNotificationCenter
            me.addFriend(self.user.id)
            
        } else {
            me.invited?.remove(self.user.id)
            if isComeFromSocket {
                Util.showSuccess(self.user.nickName + " 拒绝了您的好友邀请")
            } else {
                Util.showSuccess("您拒绝了 " + self.user.nickName + " 的好友邀请")
            }
        }
        
        self.heightOfInvitedView.constant = 0
        self.changeHeaderView(height:240,done: { () -> () in
            
            self.invitedId = nil
            self.updateUI()
        })
    }
}

// MARK: - NSNotificationCenter

extension ProfileViewController {
    
    
    func becomeActive() {
        // check relationship
    }
    
    func receiveFriendInvited(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            
            let json = JSON(userInfo)
            if self.user.id == json["_from"]["_id"].stringValue {
                
                self.invitedId = json["_id"].stringValue
                
                gcd.sync(.Main, closure: { () -> () in
                    self.updateUI()
                })
            }
        }
    }
    
    func receiveFriendApproved(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            
            let json = JSON(userInfo)
            if self.user.id == json["_from"]["_id"].stringValue {
                
                gcd.sync(.Main, closure: { () -> () in
                    self.addFriendToMe(true)
                })
            }
        }
    }
    
    func receiveFriendDeclined(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let json = JSON(userInfo)
            
            if self.user.id == json["_from"]["_id"].stringValue {
                
                gcd.sync(.Main, closure: { () -> () in
                    self.addFriendToMe(false)
                })
            }
        }
    }
}
