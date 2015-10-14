//
//  FriendListViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class FriendListViewController: BaseTableViewController {
    
    @IBOutlet weak var addFriendButton: UIButton!
    
    var friends = [UserEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerForNotifications()
        
        Util.changeImageColorForButton(addFriendButton,color: UIColor.whiteColor())
        
        self.getFriends()
        
        updateBadgeNumber()
    }
    
    override func viewWillAppear(animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow() {
            let myfriends = me.friends ?? []
            
            if indexPath.section == 0 {
                
                let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! InvitationCell
                
                if let notification = cell.friendInvitedNotification where notification != me.friendInvitations.get(indexPath.row) { // approved or declined
                    
                    self.updateBadgeNumber()
                    self.tableView.beginUpdates()
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    if myfriends.contains(notification.from.id) {
                        self.friends.insert(notification.from, atIndex: 0)
                        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation:  .Automatic)
                        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
                    }
                    self.tableView.endUpdates()
                }
            } else if indexPath.section == 1 {
                
                if !myfriends.contains(self.friends[indexPath.row].id) { // remove friend
                    self.friends.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Middle)
                    self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
                    return
                }
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
        super.viewWillAppear(animated)
    }
    
    override func becomeActive() {
        // recalculate badge number
        self.getFriends()
        
        updateBadgeNumber()
    }

}

// MARK: - Private Methodes 

extension FriendListViewController {
    
    private func getFriends(){
        
        AlamofireController.request(.GET, "/friends", success: { (result) -> () in
            self.friends = UserEntity.collection(result)!
            self.friends.sort({
                
                if let msg1 = $0.lastMessage, msg2 = $1.lastMessage {
                    return msg1.createDate.timeIntervalSinceNow > msg2.createDate.timeIntervalSinceNow
                }
                if $0.lastMessage == nil && $1.lastMessage != nil {
                    return false
                }
                
                if $0.lastMessage != nil && $1.lastMessage == nil {
                    return true
                }
                
                return false
            })
            self.tableView.reloadData()
        }) { _ in
            let emptyView = Util.createViewWithNibName("EmptyFriends")
            self.tableView.backgroundView = emptyView
        }
    }
    
    private func updateBadgeNumber() {
        if let tabBarController = navigationController?.tabBarController as? TabBarController {
            tabBarController.updateBadgeNumber()
        }
    }
}

// MARK: - UITableView DataSource

extension FriendListViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return me.friendInvitations.count
        }
        
        if section == 1 {
            return self.friends.count
        }
        
        return 0
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("InvitationCell", forIndexPath: indexPath) as! InvitationCell
            cell.friendInvitedNotification = me.friendInvitations.get(indexPath.row)
            cell.delegate = self
            
            cell.setupDisplay()
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
            
            cell.user = self.friends[indexPath.row]
            
            cell.setupDisplay()
            
            return cell
        }
    }
    
}

// MARK: - UITableView Delegate

extension FriendListViewController {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            
            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
            vc.user = me.friendInvitations.get(indexPath.item)!.from
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.section == 1 {
            
            let vc = MessageViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.friend = self.friends[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if me.friendInvitations.count < 1 { return nil }
        if section == 0 {
            return "未处理的好友请求"
        } else {
            return "最近的消息"
        }
    }
}

// MARK: - FriendInvitationCell Delegate

extension FriendListViewController: FriendInvitationCellDelegate {
    
    func friendInvitationAccept(cell: InvitationCell) {
        
        AlamofireController.request(.PATCH, "/invitations/\(cell.friendInvitedNotification.id)", parameters: ["result": "accept"], success: { (result) -> () in
            
            self.tableView.beginUpdates()
            if let indexPath = self.tableView.indexPathForCell(cell) {
                me.friendInvitations.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
            if me.addFriend(cell.friendInvitedNotification.from.id) {
                self.friends.insert(cell.friendInvitedNotification.from, atIndex: 0)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation:  .Automatic)
            }
            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
            self.tableView.endUpdates()
            self.updateBadgeNumber()
            
        })
    }
    
    func friendInvitationDeclined(cell: InvitationCell) {
        
        Util.alert(self, title: "拒绝好友邀请", message: "拒绝 " + cell.friendInvitedNotification.from.nickName + " 的好友邀请么") { _ in
            
            AlamofireController.request(.PATCH, "/invitations/\(cell.friendInvitedNotification.id)", parameters: ["result": "refuse"], success: { (result) -> () in
                
                me.invitations?.remove(cell.friendInvitedNotification.from.id)
                
                if let indexPath = self.tableView.indexPathForCell(cell) {
                    me.friendInvitations.removeAtIndex(indexPath.row)
                    self.tableView.beginUpdates()
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
                    self.tableView.endUpdates()
                }
                self.updateBadgeNumber()
                
            })
        }
    }
}

// MARK: - NSNotificationCenter

extension FriendListViewController {
    
    private func registerForNotifications() {
        ListenerEvent.Message.addObserver(self, selector: Selector("receiveMessage:"))
        ListenerEvent.FriendAccepted.addObserver(self, selector: Selector("receiveFriendAccepted:"))
        ListenerEvent.FriendBreak.addObserver(self, selector: Selector("receiveFriendBreak:"))
    }
    
    func receiveMessage(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let json = JSON(userInfo)
            
            let user = self.friends.find{ $0.id == json["from"]["id"].stringValue }
            
            if let user = user {
                
                let message = MessageEntity(json)
                message.to = me
                message.from = user
                user.lastMessage = message
                
                let row = self.friends.indexOf(user)!
                let indexPath = NSIndexPath(forRow: row, inSection: 1)
                
                if 0 == row {
                    gcd.sync(.Main){
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    }
                } else {
                    self.friends.remove(user)
                    self.friends.insert(user, atIndex: 0)
                    
                    gcd.sync(.Main){
                        
                        let firstIndexPath =  NSIndexPath(forRow: 0, inSection: 1)
                        
                        self.tableView.beginUpdates()
                        self.tableView.moveRowAtIndexPath(indexPath, toIndexPath: firstIndexPath)
                        self.tableView.endUpdates()
                        
                        self.tableView.beginUpdates()
                        self.tableView.reloadRowsAtIndexPaths([firstIndexPath], withRowAnimation: .Automatic)
                        self.tableView.endUpdates()
                    }
                }
            }
        }
    }
    
    func receiveFriendAccepted(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            
            let from = UserEntity(JSON(userInfo)["from"])
            
            let index = self.friends.indexOf { $0.id == from.id }
            
            if index == nil {
                self.friends.insert(from, atIndex: 0)
                gcd.sync(.Main, closure: { () -> () in
                    self.tableView.beginUpdates()
                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation:  .Automatic)
                    self.tableView.endUpdates()
                })
            }
        }
    }
    
    func receiveFriendBreak(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            
            let from = UserEntity(JSON(userInfo)["from"])
            
            let index = self.friends.indexOf { $0.id == from.id }
            
            if let index = index {
                self.friends.removeAtIndex(index)
                gcd.sync(.Main, closure: { () -> () in
                    self.tableView.beginUpdates()
                    self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)], withRowAnimation:  .Automatic)
                    self.tableView.endUpdates()
                })
            }
        }
    }
}
