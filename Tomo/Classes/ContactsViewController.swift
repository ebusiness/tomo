//
//  ContactsViewController.swift
//  Tomo
//
//  Created by ebuser on 2016/01/28.
//  Copyright © 2016年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class ContactsViewController: UITableViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    @IBOutlet weak var infoLabel: UILabel!

    var friends = [UserEntity]()

    var isLoading = false

    override func viewDidLoad() {

        super.viewDidLoad()

        self.loadContacts()

        self.configEventObserver()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - UITableView datasource

extension ContactsViewController {

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        if me.friendInvitations.count > 0 {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if me.friendInvitations.count > 0 {

            switch section {
            case 0:
                return me.friendInvitations.count
            default:
                return self.friends.count
            }

        } else {
            return self.friends.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        func makeInvitationCell() -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendInvitationCell", forIndexPath: indexPath) as! FriendInvitationTableViewCell
            cell.invitation = me.friendInvitations[indexPath.item]
            cell.delegate = self
            return cell
        }

        func makeFriendCell() -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as! ContactTableViewCell
            cell.user = self.friends[indexPath.item]
            return cell
        }

        if me.friendInvitations.count > 0 {

            switch indexPath.section {
            case 0:
                return makeInvitationCell()
            default:
                return makeFriendCell()
            }

        } else {
            return makeFriendCell()
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if me.friendInvitations.count > 0 {

            switch section {
            case 0:
                return "未处理的好友请求"
            default:
                return "联系人"
            }

        } else {
            return nil
        }
    }
}

// MARK: - UITableView delegate

extension ContactsViewController {

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if me.friendInvitations.count > 0 {

            switch indexPath.section {
            case 0:
                return 88
            default:
                return 66
            }

        } else {
            return 66
        }
    }

    // Do this for eliminate the gap between the friend list sction and navigation bar.
    // that gap will appear when no invitaion and the friend list is the first section.
    // TODO: Just DONT know the meaning of these values...
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if me.friendInvitations.count == 0 {
            return 10
        }
        return 38
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController

        if me.friendInvitations.count > 0 {

            switch indexPath.section {
            case 0:
                vc.user = me.friendInvitations[indexPath.item].from
            default:
                vc.user = self.friends[indexPath.item]
            }

        } else {
            vc.user = self.friends[indexPath.item]
        }

        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Internal Methods

extension ContactsViewController {

    private func loadContacts() {

        // skip if already in loading
        if self.isLoading {
            return
        }

        self.isLoading = true

        Router.Contact.All.response {

            self.loadingIndicator.stopAnimating()

            if $0.result.isFailure {
                self.isLoading = false
                return
            }

            if let friends: [UserEntity] = UserEntity.collection($0.result.value!) {

                self.friends += friends

                // let table view display new contents
                self.appendRows(friends.count, inSection: me.friendInvitations.count > 0 ? 1 : 0)
            }
        }
    }

    // Append specific number of rows on table view
    private func appendRows(rows: Int, inSection section: Int) {

        let firstIndex = self.friends.count - rows
        let lastIndex = self.friends.count

        var indexPathes = [NSIndexPath]()

        for index in firstIndex..<lastIndex {
            indexPathes.push(NSIndexPath(forRow: index, inSection: section))
        }

        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPathes, withRowAnimation: .Fade)
        tableView.endUpdates()
    }
}

// MARK: - Event Observer

extension ContactsViewController {

    private func configEventObserver() {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRefuseInvitation:", name: "didRefuseInvitation", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didAcceptInvitation:", name: "didAcceptInvitation", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDeleteFriend:", name: "didDeleteFriend", object: me)

        // notification from background thread
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveFriendInvitation", name: "didReceiveFriendInvitation", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didMyFriendInvitationAccepted:", name: "didMyFriendInvitationAccepted", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFriendBreak:", name: "didFriendBreak", object: me)
    }

    // This method is called for sync this view controller and accout model after refuse invitation
    func didRefuseInvitation(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let index = userInfo["indexOfRemovedInvitation"] as? Int else { return }

        // update tableview, if the number of my invitation is zero, remove the whole section of 0
        // otherwise, remove the corresponding row in section 0, note the invitation data is referring
        // the accout model directly, so the data is removed just in accout model, no need to do that here
        self.tableView.beginUpdates()
        if me.friendInvitations.count > 0 {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .Automatic)
        } else {
            self.tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        }
        self.tableView.endUpdates()
    }

    // This method is called for sync this view controller and accout model after accept invitation
    func didAcceptInvitation(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let index = userInfo["indexOfRemovedInvitation"] as? Int else { return }
        guard let friend = userInfo["userEntityOfNewFriend"] as? UserEntity else { return }

        // note the invitation data is referring the account model, but friends data is not.
        // so the account model already removed the accepted invitation, but the friends data
        // still need to be sync with account model manually
        self.friends.insert(friend, atIndex: 0)

        self.tableView.beginUpdates()
        // insert the friend data
        // if the number of my invitation is zero, remove the whole section of 0
        // otherwise, remove the corresponding row in section 0
        if me.friendInvitations.count > 0 {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .Automatic)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 1)], withRowAnimation: .Automatic)
        } else {
            self.tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .Automatic)
        }
        self.tableView.endUpdates()
    }

    // This method is called for sync this view controller and accout model after delete friend
    func didDeleteFriend(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let id = userInfo["idOfDeletedFriend"] as? String else { return }
        guard let index = self.friends.indexOf({ $0.id == id }) else { return }

        // sync friends data with account model manually
        self.friends.removeAtIndex(index)

        // update tableview, if the number of my invitation is zero, insert into section 1
        // otherwise, remove the corresponding row in section 0
        self.tableView.beginUpdates()
        if me.friendInvitations.count > 0 {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 1)], withRowAnimation: .Automatic)
        } else {
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .Automatic)
        }
        self.tableView.endUpdates()
    }

    // This method is called for sync this view controller and accout model after receive friend invitation
    func didReceiveFriendInvitation() {

        // this method is called from background thread (because it fired from notification center)
        // must switch to main thread for UI updating
        gcd.sync(.Main) {

            // update tableview, if the number of my invitation is 1, insert whole section of 0
            // otherwise, insert the corresponding row in section 0 row0
            self.tableView.beginUpdates()
            if me.friendInvitations.count == 1 {
                self.tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            } else {
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
            }
            self.tableView.endUpdates()
        }
    }

    // This method is called for sync this view controller and accout model after my friend invitation was accepted
    func didMyFriendInvitationAccepted(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let newFriend = userInfo["userEntityOfNewFriend"] as? UserEntity else { return }

        self.friends.insert(newFriend, atIndex: 0)

        // this method is called from background thread (because it fired from notification center)
        // must switch to main thread for UI updating
        gcd.sync(.Main) {

            // update tableview, if the number of my invitation is zero, insert into section 0
            // otherwise, insert the corresponding row in section 1
            self.tableView.beginUpdates()
            if me.friendInvitations.count == 0 {
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
            } else {
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .Automatic)
            }
            self.tableView.endUpdates()
        }
    }

    // This method is called for sync this view controller and accout model after someone dump me
    func didFriendBreak(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let brokenUser = userInfo["userEntityOfBrokenFriend"] as? UserEntity else { return }
        guard let index = self.friends.indexOf({ $0.id == brokenUser.id }) else { return }

        self.friends.removeAtIndex(index)

        // this method is called from background thread (because it fired from notification center)
        // must switch to main thread for UI updating
        gcd.sync(.Main) {

            // update tableview, if the number of my invitation is zero, remove from section 0
            // otherwise, insert the corresponding row from section 1
            self.tableView.beginUpdates()
            if me.friendInvitations.count == 0 {
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
            } else {
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)], withRowAnimation: .Automatic)
            }
            self.tableView.endUpdates()
        }
    }
}

// MARK: - ContactTableViewCell

final class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!

    var user: UserEntity! {
        didSet { self.configDisplay() }
    }

    private func configDisplay() {

        if let photo = user.photo {
            self.avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: TomoConst.Image.DefaultAvatar)
        }

        self.nickNameLabel.text = user.nickName
    }
}

// MARK: - FriendInvitationTableViewCell

final class FriendInvitationTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!

    weak var delegate: UIViewController!

    var invitation: NotificationEntity! {
        didSet { self.configDisplay() }
    }

    private func configDisplay() {

        let user = invitation.from

        if let photo = user.photo {
            self.avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: TomoConst.Image.DefaultAvatar)
        }

        self.userNameLabel.text = user.nickName

    }

    @IBAction func accept(sender: UIButton) {

        Router.Invitation.ModifyById(id: self.invitation.id, accepted: true).response {
            if $0.result.isFailure { return }
            me.acceptInvitation(self.invitation)
        }
    }

    @IBAction func refuse(sender: UIButton) {

        Util.alert(delegate, title: "拒绝好友邀请", message: "拒绝 " + self.invitation.from.nickName + " 的好友邀请么") { _ in
            Router.Invitation.ModifyById(id: self.invitation.id, accepted: false).response {
                if $0.result.isFailure { return }
                me.refuseInvitation(self.invitation)
            }
        }
    }
}
