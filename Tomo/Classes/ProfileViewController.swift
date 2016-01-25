//
//  ProfileViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import SwiftyJSON

final class ProfileViewController: UITableViewController {

    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var genderLabel: UILabel!

    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var fullNameLabel: UILabel!

    @IBOutlet weak var birthDayLabel: UILabel!

    @IBOutlet weak var addFriendButton: UIButton!

    @IBOutlet weak var messageButton: UIButton!

    @IBOutlet weak var acceptButton: UIButton!

    @IBOutlet weak var refuseButton: UIButton!

    var user: UserEntity!

    var isFriend = false
    var isInvitedByMe = false
    var isInvitingMe = false
    
//    @IBOutlet weak var receivedInvitationCell: UITableViewCell!
//    @IBOutlet weak var sentInvitationCell: UITableViewCell!
//    @IBOutlet weak var sendMessageCell: UITableViewCell!
//    @IBOutlet weak var addFriendCell: UITableViewCell!

//    let invitedSection = 0
//    let sendMessageSection = 3

    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.determineUserStatus()

        self.configDisplay()
        
//        if self.user.id == me.id {
//            self.navigationItem.rightBarButtonItem = nil
//        }

//        self.registerForNotifications()
    }

}

// MARK: - @IBAction

extension ProfileViewController {
    
    @IBAction func Approved(sender: UIButton) {
//        inviteAction(true)
    }
    
    @IBAction func Declined(sender: UIButton) {
        Util.alert(self, title: "拒绝好友邀请", message: "拒绝 " + self.user.nickName + " 的好友邀请么") { _ in
//            self.inviteAction(false)
        }
    }

    @IBAction func moreBtnTapped(sender: AnyObject) {
        
        var optionalList = Dictionary<String,((UIAlertAction!) -> Void)!>()

        if self.user.id != me.id {
            optionalList["举报此用户"] = { (_) -> Void in
                
                Util.alert(self, title: "举报用户", message: "您确定要举报此用户吗？") { _ in
                    Router.Report.User(id: self.user.id).request
                }
            }
        }
        
        if self.user.id != me.id {
            
            if let blockUsers = me.blockUsers where blockUsers.contains(self.user.id) {
                
                optionalList["取消屏蔽"] = { (_) -> Void in
                    Router.User.Block(id: self.user.id).response {
                        if $0.result.isFailure { return }
                        me.blockUsers?.remove(self.user.id)
                    }
                }
                
            } else {
                
                optionalList["屏蔽此用户"] = { (_) -> Void in
                    
                    Util.alert(self, title: "屏蔽用户", message: "您确定要屏蔽此用户吗？") { _ in
                        Router.User.Block(id: self.user.id).response {
                            if $0.result.isFailure { return }
                            me.blockUsers?.append(self.user.id)
                        }
                    }
                }
            }
            
        }
        
        if let friends = me.friends where friends.contains(self.user.id) {
            optionalList["删除好友"] = { (_) -> Void in
                
                Util.alert(self, title: "删除好友", message: "确定删除该好友么?") { _ in
                    Router.Contact.Delete(id: self.user.id).response {
                        if $0.result.isFailure { return }
                        me.removeFriend(self.user)
//                        self.reloadButtons()
                    }
                }
            }
        }
        
        Util.alertActionSheet(self, optionalDict: optionalList)
        
    }
    
    @IBAction func addFriend(sender: UIButton) {
        
        sender.userInteractionEnabled = false
        
        Router.Invitation.SendTo(id: self.user.id).response {
            if $0.result.isFailure {
                sender.userInteractionEnabled = true
                return
            }
            
            if me.invitations == nil {
                me.invitations = []
            }
            me.invitations?.append(self.user.id)
            Util.showSuccess("已发送交友请求")
//            self.reloadButtons()

            sender.userInteractionEnabled = true
        }
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        
        let messageViewController = self.navigationController?.childViewControllers.find { ($0 as? MessageViewController)?.friend.id == self.user.id } as? MessageViewController
        
        if let messageViewController = messageViewController {
            self.navigationController?.popToViewController(messageViewController, animated: true)
        } else {
            let vc = MessageViewController()
            vc.hidesBottomBarWhenPushed = true
            
            vc.friend = self.user
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - TableView DataSource & Delegate

extension ProfileViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {

        case 0:
            return 4
        case 1:
            return 1
        case 2:
            if self.isFriend {
                return 1
            } else {
                return 0
            }
        default:
            return 0
        }
    }
}

// MARK: - private

extension ProfileViewController {
    
//    private func reloadButtons() {
//        self.tableView.beginUpdates()
//        self.tableView.reloadSections(NSIndexSet(index: invitedSection), withRowAnimation: .Automatic)
//        self.tableView.reloadSections(NSIndexSet(index: sendMessageSection), withRowAnimation: .Automatic)
//        self.tableView.endUpdates()
//    }

//    private func getUserInvitation() -> NotificationEntity? {
//        return me.friendInvitations.find { $0.from.id == self.user.id }
//    }

//    private func inviteAction(isApproved:Bool){
//
//        guard let invitation = self.getUserInvitation() else { return }
//        
//        Router.Invitation.ModifyById(id: invitation.id, accepted: isApproved).response {
//            if $0.result.isFailure { return }
//            
//            if isApproved {
//                Util.showSuccess(self.user.nickName + " 已成为您的好友")
//                me.addFriend(self.user)
//            } else {
//                Util.showSuccess("您拒绝了 " + self.user.nickName + " 的好友邀请")
//                me.removeFriend(self.user)
//            }
//            self.reloadButtons()
//        }
//    }
}

// MARK: - NSNotificationCenter

extension ProfileViewController {
    
//    private func registerForNotifications() {
//        ListenerEvent.FriendBreak.addObserver(self, selector: Selector("receiveFriendBreak:"))
//        ListenerEvent.FriendInvited.addObserver(self, selector: Selector("receiveFriendInvited:"))
//        ListenerEvent.FriendAccepted.addObserver(self, selector: Selector("receiveFriendAccepted:"))
//        ListenerEvent.FriendRefused.addObserver(self, selector: Selector("receiveFriendRefused:"))
//    }
//    
//    private func receive(notification: NSNotification, done: ()->() ){
//        guard let userInfo = notification.userInfo else { return }
//        
//        let json = JSON(userInfo)
//        if self.user.id == json["from"]["id"].stringValue {
//            gcd.sync(.Main, closure: { () -> () in
//                done()
//            })
//        }
//    }
//    
//    func receiveFriendBreak(notification: NSNotification) {
//        self.receive(notification) {
//            self.reloadButtons()
//        }
//    }
//    
//    func receiveFriendInvited(notification: NSNotification) {
//        self.receive(notification) {
//            self.reloadButtons()
//        }
//    }
//    
//    func receiveFriendAccepted(notification: NSNotification) {
//        self.receive(notification) {
//            self.reloadButtons()
//        }
//    }
//    
//    func receiveFriendRefused(notification: NSNotification) {
//        self.receive(notification) {
//            self.reloadButtons()
//        }
//    }
}

// MARK: - Internal methods

extension ProfileViewController {

    private func determineUserStatus() {

        if let myFriends = me.friends {
            self.isFriend = myFriends.contains(self.user.id)
        }

        if let myInvitations = me.invitations {
            self.isInvitedByMe = myInvitations.contains(self.user.id)
        }

        if let _ = me.friendInvitations.find({ $0.from.id == self.user.id }) {
            self.isInvitingMe = true
        }
    }

    private func configDisplay() {

        self.navigationItem.title = self.user.nickName

        if let cover = self.user.cover {
            self.avatarImageView.sd_setImageWithURL(NSURL(string: cover), placeholderImage: TomoConst.Image.DefaultCover)
        }

        if let photo = self.user.photo {
            self.avatarImageView.layer.borderWidth = 2
            self.avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
            self.avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: TomoConst.Image.DefaultAvatar)
        }

        if self.user.firstName != nil && self.user.lastName != nil  {
            self.fullNameLabel.text = user.fullName()
        }

        if let gender = self.user.gender {
            self.genderLabel.text = gender
        }

        if let birthDay = self.user.birthDay {
            self.birthDayLabel.text = birthDay.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle)
        }

        if let address = self.user.address {
            self.addressLabel.text = address
        }

        self.statusLabel.text = self.user.bio

        if !self.isFriend && !self.isInvitedByMe && !self.isInvitingMe {
            self.addFriendButton.hidden = false
        }

        if self.isFriend {
            self.messageButton.hidden = false
        }

        if self.isInvitingMe {
            self.acceptButton.hidden = false
            self.refuseButton.hidden = false
            self.statusLabel.text = "\(self.user.nickName)邀请您成为好友"
        }

        if self.isInvitedByMe {
            self.statusLabel.text = "好友邀请已发送，等待对方验证通过"
        }
    }
}
