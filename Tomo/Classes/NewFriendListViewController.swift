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
    
    var friendInvitedNotifications = [Notification]()
    
    var friends = [UserEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Util.changeImageColorForButton(addFriendButton,color: UIColor.whiteColor())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateBadgeNumber"), name: kNotificationGotNewMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("becomeActive"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
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
//        self.getFriends()
//        friendInvitedNotifications = DBController.unconfirmedNotification(type: .FriendInvited)
//        tableView.reloadData()
//        
//        (navigationController?.tabBarController as? TabBarController)?.updateBadgeNumber()
    }
    
    func becomeActive() {
        ApiController.getMessage({ (error) -> Void in
            self.updateBadgeNumber()
        })
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
            
            DBController.makeAllMessageRead(friend.id)
            //            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? RecentlyFriendCell {
            //                cell.clearBadge()
            //            }
            
            (self.navigationController?.tabBarController as? TabBarController)?.updateBadgeNumber()
            
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
        if let indexPath = tableView.indexPathForCell(cell) {
            friendInvitedNotifications.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        ApiController.friendInvite(cell.friendInvitedNotification!.id!,isApproved: true, done: { (error) -> Void in
            self.updateBadgeNumber()
        })
    }
    
    func friendInvitationDeclined(cell: NewInvitationCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            friendInvitedNotifications.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        ApiController.friendInvite(cell.friendInvitedNotification!.id!,isApproved:false, done: { (error) -> Void in
            self.updateBadgeNumber()
        })
    }
}
