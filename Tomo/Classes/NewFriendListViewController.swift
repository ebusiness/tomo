//
//  NewFriendListViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NewFriendListViewController: UITableViewController {
    
    var friendInvitedNotifications = [Notification]()
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateBadgeNumber"), name: kNotificationGotNewMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("becomeActive"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        users = DBController.friends()
        
        updateBadgeNumber()
        
        ApiController.unconfirmedNotification { (error) -> Void in
            ApiController.getFriends { (error) -> Void in
                ApiController.getMessage({ (error) -> Void in
                    self.updateBadgeNumber()
                })
                
                self.updateBadgeNumber()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return friendInvitedNotifications.count
        }
        
        if section == 1 {
            return users.count
        }
        
        return 0
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("InvitationCell", forIndexPath: indexPath) as! NewInvitationCell
            cell.friendInvitedNotification = friendInvitedNotifications[indexPath.row]
            cell.delegate = self
            
            cell.setupDisplay()
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! NewFriendCell
            
            cell.user = users[indexPath.row]
            
            cell.setupDisplay()
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1 {
        
            let friend = users[indexPath.row]
            
            DBController.makeAllMessageRead(friend)
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
    
    func updateBadgeNumber() {
        users = DBController.friends()
        friendInvitedNotifications = DBController.unconfirmedNotification(type: .FriendInvited)
        tableView.reloadData()
        
        (navigationController?.tabBarController as? TabBarController)?.updateBadgeNumber()
    }
    
    func becomeActive() {
        ApiController.getMessage({ (error) -> Void in
            self.updateBadgeNumber()
        })
    }

}

// MARK: - FriendInvitationCellDelegate

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
