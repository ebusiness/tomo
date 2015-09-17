//
//  ProfileViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class ProfileViewController: ProfileBaseController {

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
        self.registerForNotifications()
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
            
            if let invitation = self.getUserInvitation() {
                
                self.invitedView.hidden = false
                
                self.heightOfInvitedView.constant = 44
                self.changeHeaderView(height:284)
            } else if let invitations = me.invitations where invitations.contains(self.user.id) {
                //invited
            } else if user.id != me.id  {
                self.addFriendButton.hidden = false
            }
        }
    }
    
    @IBAction func Approved(sender: UIButton) {
        
        inviteAction(true)
    }
    
    @IBAction func Declined(sender: UIButton) {
        Util.alert(self, title: "拒绝好友邀请", message: "拒绝 " + self.user.nickName + " 的好友邀请么") { _ in
            self.inviteAction(false)
        }
    }
    
    @IBAction func deleteFriend(sender: UIButton) {
        
        Util.alert(self, title: "删除好友", message: "确定删除该好友么?", action: { (_) -> Void in
            
            AlamofireController.request(.DELETE, "/friends/\(self.user.id)", success: { _ in
                
                me.friends?.remove(self.user.id)
//                self.navigationController?.popViewControllerAnimated(true)
                self.updateUI()

            })
        })
        
    }
    
    @IBAction func addFriend(sender: UIButton) {
        
        Util.showHUD()
        
        var param = Dictionary<String, String>()
        param["id"] = self.user.id
        
        AlamofireController.request(.POST, "/invitations", parameters: param, success: { _ in
            
            if me.invitations == nil {
                me.invitations = []
            }
            me.invitations?.append(self.user.id)
            Util.showSuccess("已发送交友请求")
            self.updateUI()
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
    
    private func getUserInvitation() -> NotificationEntity? {
        return me.friendInvitations.find { $0.from.id == self.user.id }
    }
    
    private func inviteAction(isApproved:Bool){
        
        if let invitation = self.getUserInvitation() {
            
            Util.showHUD()
            var param = Dictionary<String, String>()
            param["result"] = isApproved ? "accept" : "refuse"
            
            AlamofireController.request(.PATCH, "/invitations/\(invitation.id)", parameters: param, success: { _ in
                me.friendInvitations = me.friendInvitations.filter{ $0.from.id != self.user.id }
                self.addFriendToMe(isApproved,isComeFromSocket: false)
            })
        }
    }
    
    private func addFriendToMe(isApproved:Bool,isComeFromSocket: Bool = true){
        
        if isApproved {
            
            Util.showSuccess(self.user.nickName + " 已成为您的好友")
//                me.friendInvitations = me.friendInvitations?.filter{ $0.from.id != self.user.id } //already do it in the friendlistViewController when called by NSNotificationCenter
            me.addFriend(self.user.id)
            
        } else {
            me.invitations?.remove(self.user.id)
            if !isComeFromSocket {
                Util.showMessage("您拒绝了 " + self.user.nickName + " 的好友邀请")
            }
        }
        
        self.heightOfInvitedView.constant = 0
        self.changeHeaderView(height:240,done: { () -> () in
            
            self.updateUI()
        })
    }
}

// MARK: - NSNotificationCenter

extension ProfileViewController {
    
    private func registerForNotifications() {
        ListenerEvent.FriendInvited.addObserver(self, selector: Selector("receiveFriendInvited:"))
        ListenerEvent.FriendAccepted.addObserver(self, selector: Selector("receiveFriendAccepted:"))
        ListenerEvent.FriendRefused.addObserver(self, selector: Selector("receiveFriendRefused:"))
    }
    
    private func receive(notification: NSNotification, done: (json: JSON)->() ){
        if let userInfo = notification.userInfo {
            
            let json = JSON(userInfo)
            if self.user.id == json["from"]["id"].stringValue {
                gcd.sync(.Main, closure: { () -> () in
                    done(json: json)
                })
            }
        }
    }
    
    func receiveFriendInvited(notification: NSNotification) {
        self.receive(notification, done: { json in
            
            let invitation = NotificationEntity(json)
            invitation.id = invitation.targetId
            
            me.friendInvitations.append( invitation )
            
            self.updateUI()
        })
    }
    
    func receiveFriendAccepted(notification: NSNotification) {
        self.receive(notification, done: { _ in
            self.addFriendToMe(true)
        })
    }
    
    func receiveFriendRefused(notification: NSNotification) {
        self.receive(notification, done: { _ in
            self.addFriendToMe(false)
        })
    }
}
