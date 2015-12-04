//
//  ProfileViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import SwiftyJSON

final class ProfileViewController: ProfileBaseController {

    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var birthDayLabel: UILabel!
    
    @IBOutlet weak var receivedInvitationCell: UITableViewCell!
    @IBOutlet weak var sentInvitationCell: UITableViewCell!

    @IBOutlet weak var sendMessageCell: UITableViewCell!
    @IBOutlet weak var addFriendCell: UITableViewCell!
    
    let invitedSection = 0
    let sendMessageSection = 3

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.reloadButtons()
        
        if self.user.id == me.id {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.tableView.reloadSections(NSIndexSet(index: invitedSection), withRowAnimation: .Automatic)
        self.tableView.reloadSections(NSIndexSet(index: sendMessageSection), withRowAnimation: .Automatic)
        self.registerForNotifications()
    }
    
    override func updateUI() {
        super.updateUI()
        
        if nil != user.firstName && nil != user.lastName {
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
    }
}

// MARK: - @IBAction

extension ProfileViewController {
    
    @IBAction func Approved(sender: UIButton) {
        
        inviteAction(true)
    }
    
    @IBAction func Declined(sender: UIButton) {
        Util.alert(self, title: "拒绝好友邀请", message: "拒绝 " + self.user.nickName + " 的好友邀请么") { _ in
            self.inviteAction(false)
        }
    }

    @IBAction func moreBtnTapped(sender: AnyObject) {
        
        var optionalList = Dictionary<String,((UIAlertAction!) -> Void)!>()

        if self.user.id != me.id {
            optionalList["举报此用户"] = { (_) -> Void in
                
                Util.alert(self, title: "举报用户", message: "您确定要举报此用户吗？", action: { (action) -> Void in
                    AlamofireController.request(.POST, "/reports/users/\(self.user.id)")
                })
            }
        }
        
        if self.user.id != me.id {
            
            if let blockUsers = me.blockUsers where blockUsers.contains(self.user.id) {
                
                optionalList["取消屏蔽"] = { (_) -> Void in
                    AlamofireController.request(.POST, "/blocks", parameters: ["id": self.user.id], success: {
                        _ in
                        me.blockUsers?.remove(self.user.id)
                    })
                }
                
            } else {
                
                optionalList["屏蔽此用户"] = { (_) -> Void in
                    
                    Util.alert(self, title: "屏蔽用户", message: "您确定要屏蔽此用户吗？", action: { (action) -> Void in
                        AlamofireController.request(.POST, "/blocks", parameters: ["id": self.user.id], success: { _ in
                            me.blockUsers?.append(self.user.id)
                            self.navigationController?.popViewControllerAnimated(true)
                        })
                    })
                }
            }
            
        }
        
        if let friends = me.friends where friends.contains(self.user.id) {
            optionalList["删除好友"] = { (_) -> Void in
                
                Util.alert(self, title: "删除好友", message: "确定删除该好友么?", action: { (_) -> Void in
                    AlamofireController.request(.DELETE, "/friends/\(self.user.id)", success: { _ in
                        me.removeFriend(self.user.id)
                        self.reloadButtons()
                    })
                })
            }
        }
        
        Util.alertActionSheet(self, optionalDict: optionalList)
        
    }
    
    @IBAction func addFriend(sender: UIButton) {
        
        sender.userInteractionEnabled = false
        var param = Dictionary<String, String>()
        param["id"] = self.user.id
        
        let successHandler: ((AnyObject)->()) = { _ in
            
            if me.invitations == nil {
                me.invitations = []
            }
            me.invitations?.append(self.user.id)
            Util.showSuccess("已发送交友请求")
            self.reloadButtons()
            
            sender.userInteractionEnabled = true
        }
        
        let failureHandler: (Int)->() = { _ in
            sender.userInteractionEnabled = true
        }
        
        AlamofireController.request(.POST, "/invitations", parameters: param, success: successHandler, failure: failureHandler)
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
        
        if section == invitedSection {
            // if has any friendInvitations or invitations it's will show receivedInvitationCell / sentInvitationCell in this section
            let hasInvitation = self.getUserInvitation() != nil || me.invitations?.find { $0 == self.user.id } != nil
            
            if hasInvitation {
                return 1
            } else {
                return 0
            }
        }
        
        if section == sendMessageSection {
            // if no friendInvitations or no invitations it's will show sendMessageCell / addFriendCell in this section
            let hasInvitation = self.getUserInvitation() != nil || me.invitations?.find { $0 == self.user.id } != nil
            
            if hasInvitation {
                return 0
            } else {
                return 1
            }
        }
        
        return super.tableView(self.tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == invitedSection {
            
            let cell = self.getUserInvitation() == nil ? sentInvitationCell : receivedInvitationCell
            
            return cell
        }
        
        if indexPath.section == sendMessageSection {
            
            let cell = (me.friends ?? []).contains(self.user.id) ? sendMessageCell : addFriendCell
            
            return cell
        }
        
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
}

// MARK: - private

extension ProfileViewController {
    
    private func reloadButtons() {
        self.tableView.beginUpdates()
        self.tableView.reloadSections(NSIndexSet(index: invitedSection), withRowAnimation: .Automatic)
        self.tableView.reloadSections(NSIndexSet(index: sendMessageSection), withRowAnimation: .Automatic)
        self.tableView.endUpdates()
    }
    
    private func getUserInvitation() -> NotificationEntity? {
        return me.friendInvitations.find { $0.from.id == self.user.id }
    }
    
    private func inviteAction(isApproved:Bool){
        
        if let invitation = self.getUserInvitation() {
            
            var param = Dictionary<String, String>()
            param["result"] = isApproved ? "accept" : "refuse"
            
            AlamofireController.request(.PATCH, "/invitations/\(invitation.id)", parameters: param, success: { _ in
                
                me.friendInvitations = me.friendInvitations.filter{ $0.from.id != self.user.id }
                if isApproved {
                    Util.showSuccess(self.user.nickName + " 已成为您的好友")
                    me.addFriend(self.user.id)
                } else {
                    me.invitations?.remove(self.user.id)
                    Util.showSuccess("您拒绝了 " + self.user.nickName + " 的好友邀请")
                }
                
                if let friendListViewController = (self.tabBarController?.childViewControllers.get(1) as? UINavigationController)?.childViewControllers.get(0) as? FriendListViewController {
                    if isApproved {
                        friendListViewController.friends.insert(self.user, atIndex: 0)
                    }
                    friendListViewController.tableView.reloadData()
                }
                
                self.reloadButtons()
            })
        }
    }
}

// MARK: - NSNotificationCenter

extension ProfileViewController {
    
    private func registerForNotifications() {
        ListenerEvent.FriendBreak.addObserver(self, selector: Selector("receiveFriendBreak:"))
        ListenerEvent.FriendInvited.addObserver(self, selector: Selector("receiveFriendInvited:"))
        ListenerEvent.FriendAccepted.addObserver(self, selector: Selector("receiveFriendAccepted:"))
        ListenerEvent.FriendRefused.addObserver(self, selector: Selector("receiveFriendRefused:"))
    }
    
    private func receive(notification: NSNotification, done: ()->() ){
        if let userInfo = notification.userInfo {
            
            let json = JSON(userInfo)
            if self.user.id == json["from"]["id"].stringValue {
                gcd.sync(.Main, closure: { () -> () in
                    done()
                })
            }
        }
    }
    
    func receiveFriendBreak(notification: NSNotification) {
        self.receive(notification) {
            self.reloadButtons()
        }
    }
    
    func receiveFriendInvited(notification: NSNotification) {
        self.receive(notification) {
            self.reloadButtons()
        }
    }
    
    func receiveFriendAccepted(notification: NSNotification) {
        self.receive(notification) {
            self.reloadButtons()
        }
    }
    
    func receiveFriendRefused(notification: NSNotification) {
        self.receive(notification) {
            self.reloadButtons()
        }
    }
}
