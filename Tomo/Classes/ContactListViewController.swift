//
//  ContactListViewController.swift
//  Tomo
//
//  Created by starboychina on 2016/01/21.
//  Copyright © 2016年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import SwiftyJSON

final class ContactListViewController: UITableViewController {
    
    @IBOutlet weak var addFriendButton: UIButton!
    
    let invitationSection = 0
    let contactSection = 1
    
    let gcdGroup = GCDGroup()
    
    var contacts = [AnyObject]() {
        didSet {
            print("contacts:\(contacts)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        Util.changeImageColorForButton(addFriendButton,color: UIColor.whiteColor())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("becomeActive"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        self.registerClosureForAccount()
        
        self.registerForNotifications()
        
        self.getContacts()
        
        updateBadgeNumber()
    }
    
    override func viewWillAppear(animated: Bool) {
//        self.automaticallyAdjustsScrollViewInsets = false
        let image = Util.imageWithColor(NavigationBarColorHex, alpha: 1)
        self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
    }
    
    @objc private func becomeActive() {
        // recalculate badge number
        self.getContacts()
        
        updateBadgeNumber()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

// MARK: - Delegation
extension ContactListViewController {
    
    func registerClosureForAccount() {
        me.addFriendInvitationsObserver { (added, removed) -> () in
            let addIndexPaths = added.keys.flatMap({ NSIndexPath(forItem: $0, inSection: self.invitationSection) })
            let removeIndexPaths = removed.keys.flatMap({ NSIndexPath(forItem: $0, inSection: self.invitationSection) })
            
            self.refreshTableView(addIndexPaths, removeIndexPaths: removeIndexPaths)
        }
        
        let contactClosure: ([Int: NSObject], [Int: NSObject]) -> () = { (added, removed) -> () in
            
            var removeIndexPaths = [NSIndexPath]()
            removed.values.forEach { removedItem in
                guard let removeId = (removedItem as? UserEntity)?.id ?? (removedItem as? GroupEntity)?.id else { return }
                
                self.contacts.each({ (index, item) -> () in
                    guard let id = (item as? UserEntity)?.id ?? (item as? GroupEntity)?.id else { return }
                    
                    if id == removeId {
                        self.contacts.removeAtIndex(index)
                        removeIndexPaths.append(NSIndexPath(forItem: index, inSection: self.contactSection))
                    }
                })
            }
            
            var indexTemp = 0
            var addIndexPaths = [NSIndexPath]()
            added.values.forEach { item in
                guard let itemid = (item as? UserEntity)?.id ?? (item as? GroupEntity)?.id else { return }
                
                guard !self.contacts.contains({
                    return itemid == ($0 as? UserEntity)?.id ?? ($0 as? GroupEntity)?.id
                }) else { return }
                
                self.contacts.insert(item, atIndex: 0)
                addIndexPaths.append(NSIndexPath(forItem: indexTemp, inSection: self.contactSection))
                indexTemp++
            }
            self.refreshTableView(addIndexPaths, removeIndexPaths: removeIndexPaths)
            
        }

        me.addFriendsObserver { (added, removed) -> () in
            contactClosure(added, removed)
        }
        me.addGroupsObserver { (added, removed) -> () in
            contactClosure(added, removed)
        }
    }
    
    func refreshTableView(addIndexPaths: [NSIndexPath], removeIndexPaths: [NSIndexPath]){
        guard removeIndexPaths.count > 0 || addIndexPaths.count > 0 else { return }
        
        gcd.sync(.Main){
            self.updateBadgeNumber()
            
            guard self.tabBarController?.selectedViewController?.childViewControllers.last is ContactListViewController else {
                self.tableView.reloadData()
                return
            }

            let textLabel = self.tableView.headerViewForSection(self.contactSection)?.textLabel
            if me.friendInvitations.count == 0 && textLabel?.text != nil {
                textLabel?.text = nil
            }

            self.tableView.beginUpdates()
            self.tableView.reloadSections(NSIndexSet(index: self.invitationSection), withRowAnimation: .Automatic)
            self.tableView.reloadSections(NSIndexSet(index: self.contactSection), withRowAnimation: .Automatic)
            self.tableView.endUpdates()
            
//            if removeIndexPaths.count > 0 {
//                let textLabel = self.tableView.headerViewForSection(self.contactSection)?.textLabel
//                if removeIndexPaths[0].section != self.invitationSection || me.friendInvitations.count > 0 || textLabel?.text == nil {
//                    self.tableView.deleteRowsAtIndexPaths(removeIndexPaths, withRowAnimation: .Right)
//                } else {
////                    self.tableView.deleteRowsAtIndexPaths(removeIndexPaths, withRowAnimation: .Right)
//                    self.tableView.reloadSections(NSIndexSet(index: self.invitationSection), withRowAnimation: .Right)
//                    textLabel?.text = nil
//                }
//            }
//            if addIndexPaths.count > 0 {
//                self.tableView.insertRowsAtIndexPaths(addIndexPaths, withRowAnimation: .Automatic)
//            }
        }
    }
    
    func refreshFriendCell(user: UserEntity){
        guard let index = self.contacts.indexOf({ ($0 as? UserEntity)?.id == user.id }) else { return }
        user.lastMessage = (self.contacts[index] as? UserEntity)?.lastMessage
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)], withRowAnimation:  .None)
    }
}

// MARK: - Private Methodes 

extension ContactListViewController {
    
    private func getContacts(){
        self.tableView.backgroundView = nil
        Router.Contact.All.response {
            if $0.result.isFailure {
                self.showEmptyViewIfNeeded()
                return
            }
            guard let value = $0.result.value else { return }
            
            let friends: [UserEntity] = UserEntity.collection(value["friends"])!
            let groups: [GroupEntity] = GroupEntity.collection(value["groups"])!
            
            self.contacts = friends
            self.contacts.insert(groups, atIndex: 0)
            
            self.contacts.sortInPlace({
                guard let msg1 = ($0 as? UserEntity)?.lastMessage ?? ($0 as? GroupEntity)?.lastMessage else { return false }
                guard let msg2 = ($1 as? UserEntity)?.lastMessage ?? ($1 as? GroupEntity)?.lastMessage else { return true }
                
                return msg1.createDate.timeIntervalSinceNow > msg2.createDate.timeIntervalSinceNow
            })
            self.tableView.reloadData()
        }
    }
    
    private func updateBadgeNumber() {
        let messageCount = me.friendInvitations.count + me.newMessages.count

        self.parentViewController?.tabBarItem.badgeValue = messageCount > 0 ? String(messageCount) : nil
        
        self.showEmptyViewIfNeeded()
    }
    
    private func showEmptyViewIfNeeded(){
        if me.friendInvitations.count == 0 && self.contacts.count == 0 {
            self.tableView.backgroundView = Util.createViewWithNibName("EmptyFriends")
        } else {
            self.tableView.backgroundView = nil
        }
    }
}

// MARK: - UITableView DataSource

extension ContactListViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == invitationSection {
            
            return me.friendInvitations.count
            
        }
        return self.contacts.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == invitationSection {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("InvitationCell", forIndexPath: indexPath) as! InvitationCell
            cell.friendInvitedNotification = me.friendInvitations.get(indexPath.row)
            
            cell.setupDisplay()
            
            return cell
            
        }
        
        if let group = self.contacts[indexPath.row] as? GroupEntity {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("MyGroupCell", forIndexPath: indexPath) as! MyGroupCell
            
            cell.group = group
            
            cell.setupDisplay()
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
        
        cell.user = self.contacts[indexPath.row] as! UserEntity
        
        cell.setupDisplay()
        
        return cell
    }
    
}

// MARK: - UITableView Delegate

extension ContactListViewController {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == invitationSection {
            
            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
            vc.user = me.friendInvitations.get(indexPath.item)!.from
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        if let group = self.contacts[indexPath.row] as? GroupEntity {
            let vc = GroupChatViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.group = group
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        let vc = MessageViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.friend = self.contacts[indexPath.row] as! UserEntity
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if me.friendInvitations.count < 1 { return nil }
        if section == invitationSection {
            return "未处理的好友请求"
        } else {
            return "最近的消息"
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if me.friendInvitations.count < 1 { return 0 }
        return 38
    }
}

// MARK: - NSNotificationCenter

extension ContactListViewController {
    
    private func registerForNotifications() {
        ListenerEvent.Message.addObserver(self, selector: Selector("receiveMessage:"))
        ListenerEvent.GroupMessage.addObserver(self, selector: Selector("receiveGroupMessage:"))
        ListenerEvent.FriendAccepted.addObserver(self, selector: Selector("receiveFriendAccepted:"))
        ListenerEvent.FriendBreak.addObserver(self, selector: Selector("receiveFriendBreak:"))
    }
    
    func receiveGroupMessage(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let json = JSON(userInfo)
        
        guard let targetId = json["targetId"].string else { return }
        
        guard let groups = self.contacts.filter({ $0 is GroupEntity }) as? [GroupEntity] else { return }
        guard let group = groups.find({$0.id == targetId}) else { return }
        
        
        let message = MessageEntity(json)
        message.from = UserEntity(json["from"])
        message.group = group
        group.lastMessage = message
        
        self.refreshMessageForListener(group)
    }
    
    func receiveMessage(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        guard let friends = self.contacts.filter({ $0 is UserEntity }) as? [UserEntity] else { return }
        
        let json = JSON(userInfo)
        guard let user = friends.find({$0.id == json["from"]["id"].stringValue}) else { return }
        
        let message = MessageEntity(json)
        message.to = me
        message.from = user
        user.lastMessage = message
        
        self.refreshMessageForListener(user)
    }
    
    func receiveFriendAccepted(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let from = UserEntity(JSON(userInfo)["from"])
        me.addFriend(from)
    }
    
    func receiveFriendBreak(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let from = UserEntity(JSON(userInfo)["from"])
        me.removeFriend(from)
    }
    
    private func refreshMessageForListener(item: AnyObject){
        guard let index = self.contacts.indexOf({
            
            if let item = item as? UserEntity {
                return ($0 as? UserEntity)?.id == item.id
            }
            return ($0 as? GroupEntity)?.id == (item as? GroupEntity)?.id
            
        }) else { return }
        
        self.contacts.removeAtIndex(index)
        self.contacts.insert(item, atIndex: 0)
        
        let indexPath = NSIndexPath(forRow: index, inSection: 1)
        
        
        gcd.sync(.Main){
            let firstIndexPath =  NSIndexPath(forRow: 0, inSection: 1)
            self.tableView.beginUpdates()
            if indexPath.row > 0 {
                self.tableView.moveRowAtIndexPath(indexPath, toIndexPath: firstIndexPath)
            }
            self.tableView.reloadRowsAtIndexPaths([firstIndexPath], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
    }
}
