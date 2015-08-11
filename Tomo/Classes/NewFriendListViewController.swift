//
//  NewFriendListViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class NewFriendListViewController: BaseTableViewController {
    
    @IBOutlet weak var addFriendButton: UIButton!
    
    var friends = [UserEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Util.changeImageColorForButton(addFriendButton,color: UIColor.whiteColor())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("becomeActive"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        SocketController.sharedInstance.addObserverForEvent(self, selector: Selector("receiveMessage:"), event: .Message)
        SocketController.sharedInstance.addObserverForEvent(self, selector: Selector("receiveFriendInvited:"), event: .FriendInvited)
        
        self.getFriends()
        
        updateBadgeNumber()
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
            "bioText": "bio",
            "firstName": "firstName",
            "lastName": "lastName",
            "birthDay": "birthDay",
            "telNo": "telNo",
            "address": "address",
            ])
        
        let messageRelationshipMapping = RKRelationshipMapping(fromKeyPath: "lastMessage", toKeyPath: "lastMessage", withMapping: messageMapping)
        userMapping.addPropertyMapping(messageRelationshipMapping)
        
        let responseDescriptorUserInfo = RKResponseDescriptor(mapping: userMapping, method: .GET, pathPattern: "/connections/friends", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        self.manager.addResponseDescriptor(responseDescriptorUserInfo)
    }

}

// MARK: - Private Methodes 

extension NewFriendListViewController {
    
    func getFriends(){
        self.manager.getObjectsAtPath("/connections/friends", parameters: nil, success: { (operation, result) -> Void in
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
            println(error)
        }
    }
    
    func updateBadgeNumber() {
        if let tabBarController = navigationController?.tabBarController as? TabBarController {
            tabBarController.updateBadgeNumber()
        }
    }
}

// MARK: - UITableView DataSource

extension NewFriendListViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return me.friendInvitations!.count
        }
        
        if section == 1 {
            return self.friends.count
        }
        
        return 0
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("InvitationCell", forIndexPath: indexPath) as! NewInvitationCell
            cell.friendInvitedNotification = me.friendInvitations?.get(indexPath.item)
            cell.delegate = self
            
            cell.setupDisplay()
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! NewFriendCell
            
            cell.user = self.friends[indexPath.row]
            
            cell.setupDisplay()
            
            return cell
        }
    }
    
}

// MARK: - UITableView Delegate

extension NewFriendListViewController {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            
            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
            
            vc.user = me.friendInvitations!.get(indexPath.item)!.from
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.section == 1 {
            
            let friend = self.friends[indexPath.row]
            
            Manager.sharedInstance.request(.PUT, kAPIBaseURLString + "/chat/\(friend.id)/open", parameters: nil, encoding: .URL)
                .responseJSON { (_, _, result, error) -> Void in
                    
                    if error != nil {
                        println(error)
                        return
                    }
                    
                    me.newMessages?.filter({ (message) -> Bool in
                        if message.from.id == friend.id {
                            me.newMessages?.remove(message)
                        }
                        return true
                    })
                    
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    self.updateBadgeNumber()
                }
            
            
            let vc = MessageViewController()
            vc.hidesBottomBarWhenPushed = true
            
            vc.friend = friend
            
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
}

// MARK: - FriendInvitationCell Delegate

extension NewFriendListViewController: FriendInvitationCellDelegate {
    
    func friendInvitationAccept(cell: NewInvitationCell) {
        
        if let indexPath = tableView.indexPathForCell(cell), invitation = me.friendInvitations?.removeAtIndex(indexPath.row) {
            Manager.sharedInstance.request(.PATCH, kAPIBaseURLString + "/notifications/\(invitation.id)", parameters: ["result": "approved"], encoding: .URL)
                .responseJSON { (_, _, result, error) -> Void in
                    if error != nil {
                        println(error)
                        return
                    }
                    self.friends.insert(invitation.from, atIndex: 0)
                    
                    self.updateBadgeNumber()
                    
                    self.tableView.beginUpdates()
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation:  .Automatic)
                    self.tableView.endUpdates()
            }
        }
    }
    
    func friendInvitationDeclined(cell: NewInvitationCell) {
        
        if let indexPath = tableView.indexPathForCell(cell), invitation = me.friendInvitations?.removeAtIndex(indexPath.row) {
            Manager.sharedInstance.request(.PATCH, kAPIBaseURLString + "/notifications/\(invitation.id)", parameters: ["result": "declined"], encoding: .URL)
                .responseJSON { (_, _, result, error) -> Void in
                    if error != nil {
                        println(error)
                        return
                    }
                    
                    self.updateBadgeNumber()
                    
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }
}

// MARK: - NSNotificationCenter

extension NewFriendListViewController {
    
    
    func becomeActive() {
        // recalculate badge number
    }
    
    func receiveMessage(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let json = JSON(userInfo)
            
            let user = self.friends.find{ $0.id == json["_from"]["_id"].stringValue }
            
            if let user = user {
                
                let message = MessageEntity()
                message.id = json["_id"].stringValue
                message.content = json["content"].stringValue
                message.createDate = json["createDate"].stringValue.toDate(format: "yyyy-MM-dd't'HH:mm:ss.SSSZ")
                
//                message.owner = me
                message.from = user
                user.lastMessage = message
                me.newMessages?.insert(message, atIndex: 0)
                
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: self.friends.indexOf(user)!, inSection: 1)], withRowAnimation: .Automatic)
                
                self.updateBadgeNumber() // TODO - optimization
            }
        }
    }
    
    func receiveFriendInvited(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let json = JSON(userInfo)
            
            let notification = NotificationEntity()
            notification.id = json["_id"].stringValue
            notification.createDate = json["createDate"].stringValue.toDate(format: "yyyy-MM-dd't'HH:mm:ss.SSSZ")
            
            let user = json["_from"]
            
            let from = UserEntity()
            from.id = user["_id"].stringValue
            from.photo = user["photo"].stringValue
            from.nickName = user["nickName"].stringValue
            
            notification.from = from
            
//            me.friendInvitations = ( me.friendInvitations ?? [NotificationEntity]() )
//            me.friendInvitations!.insert(notification, atIndex: 0)
            me.friendInvitations?.insert(notification, atIndex: 0)
            
//            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation:  .Automatic)
//            self.tableView.endUpdates()
            
            self.updateBadgeNumber()
        }

    }
}
