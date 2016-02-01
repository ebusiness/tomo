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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.friends.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as! ContactTableViewCell
        cell.user = self.friends[indexPath.item]
        return cell
    }
}

// MARK: - UITableView delegate

extension ContactsViewController {

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController

        vc.user = self.friends[indexPath.item]

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
                self.appendRows(friends.count)
            }
        }
    }

    // Append specific number of rows on table view
    private func appendRows(rows: Int) {

        let firstIndex = self.friends.count - rows
        let lastIndex = self.friends.count

        var indexPathes = [NSIndexPath]()

        for index in firstIndex..<lastIndex {
            indexPathes.push(NSIndexPath(forRow: index, inSection: 0))
        }

        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPathes, withRowAnimation: .Fade)
        tableView.endUpdates()
    }
}

// MARK: - Event Observer

extension ContactsViewController {

    private func configEventObserver() {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didAcceptInvitation:", name: "didAcceptInvitation", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDeleteFriend:", name: "didDeleteFriend", object: me)

        // notification from background thread
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didMyFriendInvitationAccepted:", name: "didMyFriendInvitationAccepted", object: me)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFriendBreak:", name: "didFriendBreak", object: me)
    }

    // This method is called for sync this view controller and accout model after accept invitation
    func didAcceptInvitation(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let friend = userInfo["userEntityOfNewFriend"] as? UserEntity else { return }

        // note the invitation data is referring the account model, but friends data is not.
        // so the account model already removed the accepted invitation, but the friends data
        // still need to be sync with account model manually
        self.friends.insert(friend, atIndex: 0)

        // insert the friend data in table view
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .Automatic)
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
        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .Automatic)
        self.tableView.endUpdates()
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

            // update tableview, insert the corresponding row in section 0
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
    }

    // This method is called for sync this view controller and accout model after someone dump me
    func didFriendBreak(notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let brokenUserId = userInfo["userIdOfBrokenFriend"] as? String else { return }
        guard let index = self.friends.indexOf({ $0.id == brokenUserId }) else { return }

        self.friends.removeAtIndex(index)

        // this method is called from background thread (because it fired from notification center)
        // must switch to main thread for UI updating
        gcd.sync(.Main) {

            // update tableview, delete the corresponding row from section 0
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
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
