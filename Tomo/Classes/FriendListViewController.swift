//
//  FriendListViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/09.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

enum FriendListDisplayMode {
    case Chat, SearchResult, GroupMember
}

class FriendListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    var friendInvitedNotifications = [Notification]()
    var users = [User]()

    var group: Group?
    
    var displayMode = FriendListDisplayMode.Chat
    
    var deletedIds = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = rightBarButtonItem()
    }
    
    func rightBarButtonItem() -> UIBarButtonItem? {
        switch displayMode {
        case .Chat:
            return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addFriend"))
        case .SearchResult:
            return nil
        case .GroupMember:
            return group!.isMyGroup() ? editButtonItem() : nil
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateBadgeNumber"), name: kNotificationGotNewMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("becomeActive"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        if displayMode == .Chat {
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
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if deletedIds.count > 0 {
            //api
            ApiController.expelGroup(group!.id!, userIds: deletedIds, done: { (error) -> Void in
                self.deletedIds.removeAll(keepCapacity: false)
            })
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Action
    
    func addFriend() {
        performSegueWithIdentifier("SegueAddFriend", sender: nil)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: animated)
        
//        if !editing && deletedIds.count > 0 {
//            //api
//            ApiController.expelGroup(group.id!, userIds: deletedIds, done: { (error) -> Void in
//                self.deletedIds.removeAll(keepCapacity: false)
//            })
//        }
    }
    
    // MARK: - Notification
    
    func updateBadgeNumber() {
        users = DBController.friends()
        friendInvitedNotifications = DBController.unconfirmedNotification(type: .FriendInvited)
        tableView.reloadData()
        
        (navigationController?.tabBarController as? TabBarController)?.updateBadgeNumber()
    }
    
    func becomeActive() {
        if displayMode == .Chat {
            ApiController.getMessage({ (error) -> Void in
                self.updateBadgeNumber()
            })
        }
    }
}

extension FriendListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && displayMode == .Chat {
            return 1
        }
        
        if section == 1 {
            return users.count
        }

        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        }
        
        if displayMode == .Chat {
            return 70
        }
        
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        }
        
        let friend = users[indexPath.row]
        
        if displayMode == .Chat {
            let cell = tableView.dequeueReusableCellWithIdentifier("RecentlyFriendCell", forIndexPath: indexPath) as! RecentlyFriendCell
            cell.unreadCount = DBController.unreadCount(friend)
            cell.friend = friend
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
        
        cell.friend = friend
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            performSegueWithIdentifier("SegueNewNotification", sender: nil)
        }
        
        if indexPath.section == 1 {
            let friend = users[indexPath.row]
            
            switch displayMode {
            case .Chat:
                DBController.makeAllMessageRead(friend)
                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? RecentlyFriendCell {
                    cell.clearBadge()
                }
                (self.navigationController?.tabBarController as? TabBarController)?.updateBadgeNumber()
                
                let vc = MessageViewController()
                
                vc.friend = friend

                navigationController?.pushViewController(vc, animated: true)
            case .SearchResult, .GroupMember:
                let vc = Util.createViewControllerWithIdentifier("AccountEditViewController", storyboardName: "Account") as! AccountEditViewController
                vc.user = friend
                vc.readOnlyMode = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }

    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let group = group {
            if !group.isMyGroup() {
                return false
            }
        } else {
            return false
        }
        
        let user = users[indexPath.row]
        return user.id != Defaults["myId"].string
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deletedIds.append(users[indexPath.row].id!)
            
            users.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

}

