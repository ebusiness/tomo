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
    
    private var invitationContacts = [NotificationEntity]()
    private var MessageContacts = [NSObject]()
    
    private var contacts = [NSObject]() {
        didSet {
            gcd.async(.Default){
                self.invitationContacts = self.contacts.filter({$0 is NotificationEntity}) as! [NotificationEntity]
                self.MessageContacts = self.contacts.filter({!($0 is NotificationEntity)})
                self.contactSection = self.invitationContacts.count == 0 ? 0 : self.MessageContacts.count == 0 ? 0 : 1
                print("contactschanged")
                self.refreshTableView(oldValue, newValues: self.contacts)
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
        #if DEBUG
            self.setTestButton()
        #else
            self.getContacts()
        #endif
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
        
        self.contacts = items
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
        print("#############################")
        print("numberOfSections:\(self.tableView.numberOfSections)")
        print("invitationSection:\(self.invitationSection)")
        print("contactSection:\(self.contactSection)")
        print("oldValues Count:\(oldValues.count)")
        print("newValues Count:\(newValues.count)")
        
        let (added, removed) = Util.diff(oldValues, rightValue: newValues)
        guard added.count > 0 || removed.count > 0 else { return }
        
        print("added Count:\(added.count)")
        print("removed Count:\(removed.count)")
        
        var removeIndexPaths = self.indexPathsOfChanged(removed, values: oldValues)
        var addIndexPaths = self.indexPathsOfChanged(added, values: newValues)
        
        print("##invitationContacts Count:\(invitationContacts.count)")
        print("##MessageContacts Count:\(MessageContacts.count)")
        
        gcd.sync(.Main){
            
            self.updateBadgeNumber()
            
            guard self.tabBarController?.selectedViewController?.childViewControllers.last is ContactListViewController else {
                self.tableView.reloadData()
                return
            }
            
            self.tableView.beginUpdates()
            // /////////////////////////////
            if self.tableView.numberOfSections == 0 {
                self.tableView.insertSections(NSIndexSet(index: self.invitationSection), withRowAnimation: .Middle)
                if self.contactSection != self.invitationSection {
                    self.tableView.insertSections(NSIndexSet(index: self.contactSection), withRowAnimation: .Middle)
                }
            }
            
            
            if self.tableView.numberOfSections == 1 {
                if self.invitationContacts.count == 0 && self.MessageContacts.count == 0 {
                    self.tableView.deleteSections(NSIndexSet(index: self.invitationSection), withRowAnimation: .Middle)
                } else {
                    if removeIndexPaths.count > 0 {
                        self.tableView.deleteRowsAtIndexPaths(removeIndexPaths, withRowAnimation: .Middle)
                    }
                    
                    if self.contactSection != self.invitationSection {
                        if oldValues.first is NotificationEntity {
                            self.tableView.insertSections(NSIndexSet(index: self.contactSection), withRowAnimation: .Middle)
                            addIndexPaths = addIndexPaths.filter({$0.section != self.contactSection })
                        } else {
                            self.tableView.insertSections(NSIndexSet(index: self.invitationSection), withRowAnimation: .Middle)
                            addIndexPaths = addIndexPaths.filter({$0.section != self.invitationSection })
                        }
                    }
                    if addIndexPaths.count > 0 {
                        self.tableView.insertRowsAtIndexPaths(addIndexPaths, withRowAnimation: .Middle)
                    }
                }
            }
            
            if self.tableView.numberOfSections == 2 {
                
                if self.invitationContacts.count == 0 && self.MessageContacts.count == 0 {
                    self.tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
                    self.tableView.deleteSections(NSIndexSet(index: self.invitationSection), withRowAnimation: .Middle)
                }
                if self.invitationContacts.count > 0 && self.MessageContacts.count > 0 {
                    print("removeIndexPaths :\(removeIndexPaths)")
                    print("addIndexPaths :\(addIndexPaths)")
                    if removeIndexPaths.count > 0 {
                        self.tableView.deleteRowsAtIndexPaths(removeIndexPaths, withRowAnimation: .Middle)
                    }
                    if addIndexPaths.count > 0 {
                        self.tableView.insertRowsAtIndexPaths(addIndexPaths, withRowAnimation: .Middle)
                    }
                } else {
                    if self.invitationContacts.count > 0 {
                        self.tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Middle)
                        removeIndexPaths = removeIndexPaths.filter({ $0.section != 1 })
                        if removeIndexPaths.count > 0 {
                            self.tableView.deleteRowsAtIndexPaths(removeIndexPaths, withRowAnimation: .Middle)
                        }
                        if addIndexPaths.count > 0 {
                            self.tableView.insertRowsAtIndexPaths(addIndexPaths, withRowAnimation: .Middle)
                        }
                    }
                    
                    if self.MessageContacts.count > 0 {
                        self.tableView.deleteSections(NSIndexSet(index: self.invitationSection), withRowAnimation: .Middle)
                        removeIndexPaths = removeIndexPaths.filter({ $0.section != self.invitationSection })
                        if removeIndexPaths.count > 0 {
                            self.tableView.deleteRowsAtIndexPaths(removeIndexPaths, withRowAnimation: .Middle)
                        }
                        if addIndexPaths.count > 0 {
                            self.tableView.insertRowsAtIndexPaths(addIndexPaths, withRowAnimation: .Middle)
                        }
                    }
                }
            }
            self.tableView.endUpdates()
        }
    }
    
    func indexPathsOfChanged(itemsChanged: [NSObject], values: [NSObject]) -> [NSIndexPath] {
        let invitationContacts = values.filter({$0 is NotificationEntity}) as! [NotificationEntity]
        let MessageContacts = values.filter({!($0 is NotificationEntity)})
        let contactSection = invitationContacts.count == 0 ? 0 : MessageContacts.count == 0 ? 0 : 1
        
        var indexPaths = [NSIndexPath]()
        itemsChanged.forEach({ item in
            let isInvitation = item is NotificationEntity
            
            guard let index = isInvitation ? invitationContacts.indexOf({(item as? NotificationEntity) == $0 }) : MessageContacts.indexOf(item) else { return }
            
            let section = isInvitation ? self.invitationSection : contactSection
            
            indexPaths.append(NSIndexPath(forItem: index, inSection: section))
        })
        return indexPaths
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
            
            var items: [NSObject] = me.friendInvitations
            items.insert(friends, atIndex: 0)
            items.insert(groups, atIndex: 0)
            
            items.sortInPlace({
                guard let msg1 = ($0 as? UserEntity)?.lastMessage ?? ($0 as? GroupEntity)?.lastMessage else { return false }
                guard let msg2 = ($1 as? UserEntity)?.lastMessage ?? ($1 as? GroupEntity)?.lastMessage else { return true }
                
                return msg1.createDate.timeIntervalSinceNow > msg2.createDate.timeIntervalSinceNow
            })
            
            self.contacts = items
        }
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
        if self.MessageContacts.count > 0 { num++ }
        return num
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == self.invitationSection && self.invitationContacts.count > 0 {
            return self.invitationContacts.count
        }
        
        return self.MessageContacts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == self.invitationSection && self.invitationContacts.count > 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("InvitationCell", forIndexPath: indexPath) as! InvitationCell
            cell.friendInvitedNotification = self.invitationContacts.get(indexPath.row)
            
            cell.setupDisplay()
            
            return cell
            
        }
        
        if let group = self.MessageContacts[indexPath.row] as? GroupEntity {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("MyGroupCell", forIndexPath: indexPath) as! MyGroupCell
            
            cell.group = group
            
            cell.setupDisplay()
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell
        
        cell.user = self.MessageContacts[indexPath.row] as! UserEntity
        
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
        
        if let group = self.MessageContacts[indexPath.row] as? GroupEntity {
            let vc = GroupChatViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.group = group
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        let vc = MessageViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.friend = self.MessageContacts[indexPath.row] as! UserEntity
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.invitationContacts.count < 1 { return nil }
        if section != self.contactSection {
            return "未处理的好友请求"
        } else {
            return "最近的消息"
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.invitationContacts.count < 1 { return 0 }
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
    
    private func refreshMessageForListener(item: NSObject){
        guard let id = (item as? UserEntity)?.id ?? (item as? GroupEntity)?.id else { return }
        var items = self.contacts.filter({ ($0 as? UserEntity)?.id ?? ($0 as? GroupEntity)?.id == id})
        
        items.insert(item, atIndex: 0)
        
        self.contacts = items
    }
}


// MARK: - Test
extension ContactListViewController {
    private func setTestButton(){
        let btn_user = UIButton(frame: CGRectMake(10, 10, 100, 50))
        btn_user.backgroundColor = Palette.Amber.primaryColor
        btn_user.setTitle("message", forState: .Normal)
        btn_user.addTarget(self, action: "contactTest_user", forControlEvents: .TouchUpInside)
        
        let btn_invitation = UIButton(frame: CGRectMake(120, 10, 100, 50))
        btn_invitation.backgroundColor = Palette.Cyan.primaryColor
        btn_invitation.setTitle("invitation", forState: .Normal)
        btn_invitation.addTarget(self, action: "contactTest_invitation", forControlEvents: .TouchUpInside)
        
        let btn_all = UIButton(frame: CGRectMake(230, 10, 100, 50))
        btn_all.backgroundColor = Palette.Blue.primaryColor
        btn_all.setTitle("all", forState: .Normal)
        btn_all.addTarget(self, action: "contactTest_all", forControlEvents: .TouchUpInside)
        
        let btn_insertI = UIButton(frame: CGRectMake(10, 70, 100, 50))
        btn_insertI.backgroundColor = Palette.BlueGrey.primaryColor
        btn_insertI.setTitle("insertI", forState: .Normal)
        btn_insertI.addTarget(self, action: "contactTest_insertinvitation", forControlEvents: .TouchUpInside)
        
        let btn_insertM = UIButton(frame: CGRectMake(120, 70, 100, 50))
        btn_insertM.backgroundColor = Palette.BlueGrey.primaryColor
        btn_insertM.setTitle("insertF", forState: .Normal)
        btn_insertM.addTarget(self, action: "contactTest_insertfriend", forControlEvents: .TouchUpInside)
        
        let btn_insertG = UIButton(frame: CGRectMake(230, 70, 100, 50))
        btn_insertG.backgroundColor = Palette.BlueGrey.primaryColor
        btn_insertG.setTitle("insertG", forState: .Normal)
        btn_insertG.addTarget(self, action: "contactTest_insertgroup", forControlEvents: .TouchUpInside)
        
        let btn_reset = UIButton(frame: CGRectMake(340, 10, 64, 110))
        btn_reset.backgroundColor = Palette.Brown.primaryColor
        btn_reset.setTitle("reset", forState: .Normal)
        btn_reset.addTarget(self, action: "contactTest_reset", forControlEvents: .TouchUpInside)
        
        
        let header = UIView(frame: CGRectMake(0, 0, 414, 110))
        header.addSubview(btn_user)
        header.addSubview(btn_invitation)
        header.addSubview(btn_all)
        header.addSubview(btn_insertI)
        header.addSubview(btn_insertM)
        header.addSubview(btn_insertG)
        header.addSubview(btn_reset)
        self.tableView.tableHeaderView = header
    }
    
    // /////////////////////
    
    @objc private func contactTest_reset(){
        self.contacts = []
    }
    
    @objc private func contactTest_user(){
        var items = [NSObject]()
        items.append(testData_Friend)
        items.append(testData_Group)
        self.contacts = items
    }
    
    @objc private func contactTest_invitation(){
        var items = [NSObject]()
        items.append(testData_invitation)
        self.contacts = items
    }
    
    @objc private func contactTest_all(){
        var items = [NSObject]()
        items.append(testData_invitation)
        items.append(testData_Friend)
        items.append(testData_Group)
        self.contacts = items
    }
    
    @objc private func contactTest_insertinvitation(){
        var items = self.contacts ?? []
        items.append(testData_invitation)
        self.contacts = items
    }
    
    @objc private func contactTest_insertfriend(){
        var items = self.contacts ?? []
        items.append(testData_Friend)
        self.contacts = items
    }
    
    @objc private func contactTest_insertgroup(){
        var items = self.contacts ?? []
        items.append(testData_Group)
        self.contacts = items
    }
    
    // /////////////////////
    
    var testData_invitation: NotificationEntity! {
        get {
            let data = NotificationEntity()
            data.id = "111"
            data.from = UserEntity()
            data.from.id = "111"
            data.from.nickName = "1111"
            return data
        }
        
    }
    var testData_Friend: UserEntity! {
        get {
            let data = UserEntity()
            data.id = "222"
            data.nickName = "222"
            return data
        }
        
    }
    var testData_Group: GroupEntity! {
        get {
            let data = GroupEntity()
            data.id = "333"
            data.name = "333"
            return data
        }
        
    }
    
}
