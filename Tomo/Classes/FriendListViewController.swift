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

        navigationItem.rightBarButtonItem = rightBarButtonItem()
        navigationItem.title = navigationBarTitle()
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
    
    func navigationBarTitle() -> String? {
        switch displayMode {
        case .Chat:
            return "トーク"
        case .SearchResult:
            return "ユーザー"
        case .GroupMember:
            return "メンバー"
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
        
        if displayMode == .SearchResult || displayMode == .GroupMember{
            let friend = users[indexPath.row]
            return friend.tags.count > 0 ? 77 : 60
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
        
        if displayMode == .Chat {
            return self.getRecentlyFriendCell(tableView, cellForRowAtIndexPath: indexPath)
        }
        return self.getFirendCell(tableView, cellForRowAtIndexPath: indexPath)
    }
    //chat
    func getRecentlyFriendCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let friend = users[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("RecentlyFriendCell", forIndexPath: indexPath) as! RecentlyFriendCell
        cell.unreadCount = DBController.unreadCount(friend)
        cell.friend = friend
        
        cell.setHandler(false, withRight: true, handler: { (cell, state, mode) -> () in
            if state == .State3 ||  state == .State4 {
                let acvc = Util.createViewControllerWithIdentifier("AlertConfirmView", storyboardName: "ActionSheet") as! AlertConfirmViewController
                
                acvc.show(self, content: "友達を解除しますか？", action: { () -> () in
                    ApiController.connectionsBreakUsers(friend.id!, done: { (error) -> Void in
                        self.users.remove(friend)
                        if let path = tableView.indexPathForCell(cell) {
                            tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Fade)
                        }
                    })
                    
                })
            }
        })
        return cell
    }
    //user list
    func getFirendCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        
        let friend = users[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell

        cell.friend = friend
        if friend.tags.count > 0 {
            for friendtag in friend.tags {
                if let friendtag = friendtag as? Tag {
                    cell.addTag(friendtag)
                }
            }
        }
        
        var withLeft = true
        var withRight = true
        
        let myfirend = DBController.friends()
        if myfirend.contains(friend) || !cell.invitedLabel.hidden || friend.id == DBController.myUser()?.id{
            withLeft = false
        }
        if displayMode == .GroupMember {
            withRight = false
        }
        
        cell.setHandler(withLeft, withRight: withRight, handler:  { (cell, state, mode) -> () in
            
            if state == .State3 ||  state == .State4 {
                if let cell = cell as? FriendCell {
                    self.users.remove(friend)
                }
                if let path = tableView.indexPathForCell(cell) {
                    tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Fade)
                }
                //                let acvc = Util.createViewControllerWithIdentifier("AlertConfirmView", storyboardName: "ActionSheet") as! AlertConfirmViewController
                //
                //                acvc.show(self, content: "削除しますか？", action: { () -> () in
                //
                //
                //                })
            }else if state == .State1 ||  state == .State2 {
                
                ApiController.invite(friend.id!, done: { (error) -> Void in
                    if let cell = cell as? FriendCell where error == nil {
                        cell.invitedLabel.hidden = false
                        cell.setSwopeON(false)
                        Util.showSuccess("友達追加リクエストを送信しました。")
                        
                    }
                })
            }
            //println(state.rawValue )
        })
        
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
                vc.hidesBottomBarWhenPushed = true
                
                vc.friend = friend

                navigationController?.pushViewController(vc, animated: true)
            case .SearchResult, .GroupMember:
                let vc = Util.createViewControllerWithIdentifier("AccountEditViewController", storyboardName: "Setting") as! AccountEditViewController
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

