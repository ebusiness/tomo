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
    
    private let invitationSection = 0
    private var contactSection = 0
    
    private var isTableReloading = false
    
    private var invitationContacts = [NotificationEntity]()
    private var messageContacts = [NSObject]()
    
    private var contacts = [NSObject]() {
        didSet {
            gcd.async(.Default){
                while self.isTableReloading {
                    print("waiting")
                }
                let items = self.contacts
                if oldValue == items { return }
                self.isTableReloading = true
                
                self.invitationContacts = items.filter({$0 is NotificationEntity}) as! [NotificationEntity]
                self.messageContacts = items.filter({!($0 is NotificationEntity)})
                self.contactSection = self.invitationContacts.count == 0 ? 0 : self.messageContacts.count == 0 ? 0 : 1
                self.refreshTableView(oldValue, newValues: items)
            }
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
        
        self.updateBadgeNumber()
        
        self.getContacts()
    }
    
    override func viewWillAppear(animated: Bool) {
//        self.automaticallyAdjustsScrollViewInsets = false
        let image = Util.imageWithColor(NavigationBarColorHex, alpha: 1)
        self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
    }
    
    @objc private func becomeActive() {
        // recalculate badge number
        self.updateBadgeNumber()
        
        self.getContacts()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

// MARK: - Delegation
extension ContactListViewController {
    
    private func contactClosure(added: [NSObject], removed: [NSObject]) {
        var items = self.contacts
        
        removed.forEach({
            guard let itemid = ($0 as? UserEntity)?.id ?? ($0 as? GroupEntity)?.id ?? ($0 as? NotificationEntity)?.id else { return }
            
            items = items.filter({ ($0 as? UserEntity)?.id ?? ($0 as? GroupEntity)?.id ?? ($0 as? NotificationEntity)?.id != itemid })
        })
        
        added.forEach({
            guard let itemid = ($0 as? UserEntity)?.id ?? ($0 as? GroupEntity)?.id ?? ($0 as? NotificationEntity)?.id else { return }
            
            guard !items.contains({ ($0 as? UserEntity)?.id ?? ($0 as? GroupEntity)?.id ?? ($0 as? NotificationEntity)?.id == itemid }) else { return }
            items.append($0)
        })
        
        self.contacts = self.contactsSort(items, added: added)
    }
    
    func registerClosureForAccount() {
        
        me.addFriendInvitationsObserver { (added, removed) -> () in
            self.contactClosure(added, removed: removed)
        }
        
        me.addFriendsObserver { (added, removed) -> () in
            self.contactClosure(added, removed: removed)
        }
        
        me.addGroupsObserver { (added, removed) -> () in
            self.contactClosure(added, removed: removed)
        }
    }
}

// MARK: - Delegation
extension ContactListViewController {
    func refreshTableView(oldValues: [NSObject], newValues: [NSObject]){
        gcd.async(.Main){
            self.updateBadgeNumber()
        }
        guard self.tabBarController?.selectedViewController?.childViewControllers.last is ContactListViewController else {
            gcd.sync(.Main){
                self.tableView.reloadData()
            }
            self.isTableReloading = false
            return
        }
        
        let (added, removed) = Util.diff(oldValues, rightValue: newValues)
        guard added.count > 0 || removed.count > 0 else {
            self.isTableReloading = false
            return
        }
        
        var removeIndexPaths = [NSIndexPath]()
        var addIndexPaths = [NSIndexPath]()
        
        let sectionsInsert = self.sectionsNeedInsert(oldValues)
        let sectionsDelete = self.sectionsNeedDelete()
        let sectionReload = self.needReloadSection(oldValues)
        
        if !sectionReload {
            removeIndexPaths = self.indexPathsOfChanged(removed, values: oldValues)
            addIndexPaths = self.indexPathsOfChanged(added, values: newValues)
            removeIndexPaths = removeIndexPaths.filter({ !sectionsDelete.contains($0.section) })
            addIndexPaths = addIndexPaths.filter({ !sectionsInsert.contains($0.section) })
        }
        
        gcd.sync(.Main){
            self.tableView.beginUpdates()
            
            sectionsDelete.forEach({
                self.tableView.deleteSections(NSIndexSet(index: $0), withRowAnimation: .Middle)
            })
            sectionsInsert.forEach({
                self.tableView.insertSections(NSIndexSet(index: $0), withRowAnimation: .Middle)
            })
            if removeIndexPaths.count > 0 {
                self.tableView.deleteRowsAtIndexPaths(removeIndexPaths, withRowAnimation: .Middle)
            }
            if addIndexPaths.count > 0 {
                self.tableView.insertRowsAtIndexPaths(addIndexPaths, withRowAnimation: .Middle)
            }
            if sectionReload {
                self.tableView.reloadSections(NSIndexSet(index: self.invitationSection), withRowAnimation: .Middle)
            }
            self.tableView.endUpdates()
            self.isTableReloading = false
        }
    }
    
    func needReloadSection(oldValues: [NSObject]) -> Bool {// reload titleForHeaderInSection
        if self.tableView.numberOfSections != 1 { return false }
        if self.invitationContacts.count == 0 && self.messageContacts.count == 0 {
            return false
        }
        if self.invitationContacts.count > 0 && self.messageContacts.count > 0 {
            return false
        }
        
        let isInvitation = oldValues.first is NotificationEntity
        if self.invitationContacts.count > 0 && isInvitation {
            return false
        }
        if self.messageContacts.count > 0 && !isInvitation {
            return false
        }
        return true
    }
    
    func sectionsNeedInsert(oldValues: [NSObject]) -> [Int] {
        if self.tableView.numberOfSections == 2 { return [] }
        
        if self.invitationContacts.count == 0 && self.messageContacts.count == 0 {
            return []
        }
        
        var sections = [Int]()
        
        if let item = oldValues.first { // self.tableView.numberOfSections == 1
            if self.contactSection != self.invitationSection {
                let section = item is NotificationEntity ? self.contactSection : self.invitationSection
                sections.append(section)
            }
        } else {
            sections.append(self.invitationSection)
            if self.contactSection != self.invitationSection {
                sections.append(self.contactSection)
            }
        }
        return sections
    }
    
    func sectionsNeedDelete() -> [Int] {
        if self.tableView.numberOfSections == 0 { return []}
        
        var sections = [Int]()
        if self.tableView.numberOfSections == 2 {
            if self.invitationContacts.count == 0 && self.messageContacts.count == 0 {
                sections.append(self.invitationSection)
                sections.append(1)
            }
            if self.invitationContacts.count > 0 && self.messageContacts.count == 0 {
                sections.append(1)
            }
            if self.messageContacts.count > 0 && self.invitationContacts.count == 0 {
                sections.append(self.invitationSection)
            }
        } else {
            if self.invitationContacts.count == 0 && self.messageContacts.count == 0 {
                sections.append(self.invitationSection)
            }
        }
        return sections

    }
    
    func indexPathsOfChanged(itemsChanged: [NSObject], values: [NSObject]) -> [NSIndexPath] {
        let invitations = values.filter({$0 is NotificationEntity}) as! [NotificationEntity]
        let messages = values.filter({!($0 is NotificationEntity)})
        let section = invitations.count == 0 ? 0 : messages.count == 0 ? 0 : 1
        
        var indexPaths = [NSIndexPath]()
        itemsChanged.forEach({ item in
            let isInvitation = item is NotificationEntity
            
            guard let index = isInvitation ? invitations.indexOf({(item as? NotificationEntity) == $0 }) : messages.indexOf(item) else { return }
            
            let section = isInvitation ? self.invitationSection : section
            
            indexPaths.append(NSIndexPath(forItem: index, inSection: section))
        })
        return indexPaths
    }
}

extension ContactListViewController {

    func refreshFriendCell(user: UserEntity){
        guard let index = self.messageContacts.indexOf({ ($0 as? UserEntity)?.id == user.id }) else { return }
        user.lastMessage = (self.messageContacts[index] as? UserEntity)?.lastMessage
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: self.contactSection)], withRowAnimation:  .None)
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
            
            var items: [NSObject] = me.friendInvitations
            items.insert(friends, atIndex: 0)
            items.insert(groups, atIndex: 0)
            
            self.contacts = self.contactsSort(items, added: [])
        }
    }
    
    private func contactsSort(items: [NSObject], added: [NSObject]) -> [NSObject] {
        return items.sort({
            if added.contains($0) { return true }
            guard let msg1 = ($0 as? UserEntity)?.lastMessage ?? ($0 as? GroupEntity)?.lastMessage else { return false }
            guard let msg2 = ($1 as? UserEntity)?.lastMessage ?? ($1 as? GroupEntity)?.lastMessage else { return true }
            
            return msg1.createDate.timeIntervalSinceNow > msg2.createDate.timeIntervalSinceNow
        })
    }
    
    private func updateBadgeNumber() {
        let messageCount = me.friendInvitations.count + me.newMessages.count
        
        self.parentViewController?.tabBarItem.badgeValue = messageCount > 0 ? String(messageCount) : nil
        
        self.showEmptyViewIfNeeded()
    }
    
    private func showEmptyViewIfNeeded(){
        if self.contacts.count == 0 {
            self.tableView.backgroundView = Util.createViewWithNibName("EmptyFriends")
        } else {
            self.tableView.backgroundView = nil
        }
    }
}

// MARK: - UITableView DataSource

extension ContactListViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var num = 0
        if self.invitationContacts.count > 0 { num++ }
        if self.messageContacts.count > 0 { num++ }
        return num
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == self.invitationSection && self.invitationContacts.count > 0 {
            return self.invitationContacts.count
        }
        
        return self.messageContacts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == self.invitationSection && self.invitationContacts.count > 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("InvitationCell", forIndexPath: indexPath) as! InvitationCell
            cell.friendInvitedNotification = self.invitationContacts.get(indexPath.row)
            
            cell.setupDisplay()
            
            return cell
            
        }
        
        if let group = self.messageContacts[indexPath.row] as? GroupEntity {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("MyGroupCell", forIndexPath: indexPath) as! MyGroupCell
            
            cell.group = group
            
            cell.setupDisplay()
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
        
        cell.user = self.messageContacts[indexPath.row] as! UserEntity
        
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
        
        if indexPath.section == self.invitationSection && self.invitationContacts.count > 0 {
            
            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
            vc.user = self.invitationContacts.get(indexPath.item)!.from
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        if let group = self.messageContacts[indexPath.row] as? GroupEntity {
            let vc = GroupChatViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.group = group
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        let vc = MessageViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.friend = self.messageContacts[indexPath.row] as! UserEntity
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.invitationContacts.count == 0 { return nil }

        if section == self.invitationSection  {
            return "未处理的好友请求"
        } else {
            return "最近的消息"
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.invitationContacts.count == 0 { return 10 }
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
        
        self.refreshMessageForListener(json) { ($0 as? GroupEntity)?.id == targetId }
    }
    
    func receiveMessage(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let json = JSON(userInfo)
        
        self.refreshMessageForListener(json) { ($0 as? UserEntity)?.id == json["from"]["id"].stringValue }
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
    
    private func refreshMessageForListener(json: JSON, indexPredicate: (NSObject) -> Bool) {
        while self.isTableReloading {
            print("waiting")
        }
        guard let index = self.messageContacts.indexOf(indexPredicate) else { return }
        guard self.messageContacts.count > index else { return }
        self.isTableReloading = true
        
        let item = self.messageContacts.removeAtIndex(index)
        
        let message = MessageEntity(json)
        
        if let user = item as? UserEntity {
            user.lastMessage = message
            self.messageContacts.insert(user, atIndex: 0)
        } else if let group = item as? GroupEntity {
            group.lastMessage = message
            self.messageContacts.insert(group, atIndex: 0)
        }
        
        gcd.sync(.Main){
            let current = NSIndexPath(forRow: index, inSection: self.contactSection)
            if index == 0 {
                self.tableView.reloadRowsAtIndexPaths([current], withRowAnimation: .Automatic)
            } else {
                self.tableView.moveRowAtIndexPath(NSIndexPath(forRow: index, inSection: self.contactSection), toIndexPath: NSIndexPath(forRow: 0 , inSection: self.contactSection))
            }
            self.isTableReloading = false
        }
    }
}
