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
                    }
                    self.tableView.endUpdates()
                }
            } else if indexPath.section == 1 {
                
                if !myfriends.contains(self.friends[indexPath.row].id) { // remove friend
                    self.friends.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Middle)
                    return
                }
            }
        }
        super.viewWillAppear(animated)
    }
    
    override func setupMapping() {
        
        let messageMapping = RKObjectMapping(forClass: MessageEntity.self)
        messageMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "content": "content",
            "createDate": "createDate"
            ])
        
        let userMapping = RKObjectMapping(forClass: UserEntity.self)
        userMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "tomoid": "tomoid",
            "nickName": "nickName",
            "gender": "gender",
            "photo_ref": "photo",
            "cover_ref": "cover",
            "bio": "bio",
            "firstName": "firstName",
            "lastName": "lastName",
            "birthDay": "birthDay",
            "telNo": "telNo",
            "address": "address",
            ])
        
        let messageRelationshipMapping = RKRelationshipMapping(fromKeyPath: "lastMessage", toKeyPath: "lastMessage", withMapping: messageMapping)
        userMapping.addPropertyMapping(messageRelationshipMapping)
        
        let responseDescriptorUserInfo = RKResponseDescriptor(mapping: userMapping, method: .GET, pathPattern: "/friends", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        self.manager.addResponseDescriptor(responseDescriptorUserInfo)
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
        self.manager.getObjectsAtPath("/friends", parameters: nil, success: { (operation, result) -> Void in
            self.friends = result.array() as! [UserEntity]
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
        }) { (operation, error) -> Void in
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
        return 66
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
    
}

// MARK: - FriendInvitationCell Delegate

extension FriendListViewController: FriendInvitationCellDelegate {
    
    func friendInvitationAccept(cell: InvitationCell) {
        
        if let indexPath = tableView.indexPathForCell(cell) {
            let invitation = me.friendInvitations.removeAtIndex(indexPath.row)
            Manager.sharedInstance.request(.PATCH, kAPIBaseURLString + "/invitations/\(invitation.id)", parameters: ["result": "accept"], encoding: .URL)
                .responseJSON { (_, _, result, error) -> Void in
                    if error != nil {
                        println(error)
                        return
                    }
                    
                    self.tableView.beginUpdates()
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    if me.addFriend(invitation.from.id) {
                        self.friends.insert(invitation.from, atIndex: 0)
                        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation:  .Automatic)
                    }
                    self.tableView.endUpdates()
                    self.updateBadgeNumber()
            }
        }
    }
    
    func friendInvitationDeclined(cell: InvitationCell) {
        
        if let indexPath = tableView.indexPathForCell(cell) {
            let invitation = me.friendInvitations.removeAtIndex(indexPath.row)
            Manager.sharedInstance.request(.PATCH, kAPIBaseURLString + "/invitations/\(invitation.id)", parameters: ["result": "refuse"], encoding: .URL)
                .responseJSON { (_, _, result, error) -> Void in
                    if error != nil {
                        println(error)
                        return
                    }
                    me.invitations?.remove(invitation.from.id)
                    
                    self.updateBadgeNumber()
                    
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }
}

// MARK: - NSNotificationCenter

extension FriendListViewController {
    
    private func registerForNotifications() {
        SocketController.sharedInstance.addObserverForEvent(self, selector: Selector("receiveMessage:"), event: .Message)
        SocketController.sharedInstance.addObserverForEvent(self, selector: Selector("receiveFriendInvited:"), event: .FriendInvited)
        SocketController.sharedInstance.addObserverForEvent(self, selector: Selector("receiveFriendApproved:"), event: .FriendApproved)
    }
    
    func receiveMessage(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let json = JSON(userInfo)
            
            let user = self.friends.find{ $0.id == json["_from"]["_id"].stringValue }
            
            if let user = user {
                
                let message = MessageEntity(json)
                message.opened = false
                
//                message.owner = me
                message.from = user
                user.lastMessage = message
                
                if let vc = self.navigationController?.childViewControllers.last as? MessageViewController where vc.friend.id == user.id {
                    message.opened = true
                } else {
                    me.newMessages.insert(message, atIndex: 0)
                }
                
                gcd.sync(.Main, closure: { () -> () in
                    
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: self.friends.indexOf(user)!, inSection: 1)], withRowAnimation: .Automatic)
                    
                    self.updateBadgeNumber() // TODO - optimization
                })
            }
        }
    }
    
    func receiveFriendInvited(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let notification = NotificationEntity(userInfo)
            me.friendInvitations.insert(notification, atIndex: 0)
            
            gcd.sync(.Main, closure: { () -> () in
                self.updateBadgeNumber()
//                self.tableView.beginUpdates()
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation:  .Automatic)
//                self.tableView.endUpdates()
            })
            
        }
    }
    
    func receiveFriendApproved(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            
            let from = UserEntity(JSON(userInfo)["_from"])
            
            let nvitationIndex = me.friendInvitations.indexOf{$0.from.id == from.id}
            if let nvitationIndex = nvitationIndex {
                
                me.friendInvitations.removeAtIndex(nvitationIndex)
                let indexPaths = [NSIndexPath(forRow: nvitationIndex, inSection: 0)]
                
                gcd.sync(.Main, closure: { () -> () in
                    self.updateBadgeNumber()
                    self.tableView.beginUpdates()
                    self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
                    self.tableView.endUpdates()
                })
            }
            
            if me.addFriend(from.id) {
                self.friends.insert(from, atIndex: 0)
                gcd.sync(.Main, closure: { () -> () in
                    self.updateBadgeNumber()
                    self.tableView.beginUpdates()
                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation:  .Automatic)
                    self.tableView.endUpdates()
                })
            }
        }
    }
}
