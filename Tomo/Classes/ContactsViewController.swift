//
//  ContactsViewController.swift
//  Tomo
//
//  Created by ebuser on 2016/01/28.
//  Copyright © 2016 e-business. All rights reserved.
//

import UIKit

final class ContactsViewController: UITableViewController {

    @IBOutlet weak fileprivate var loadingIndicator: UIActivityIndicatorView!

    @IBOutlet weak fileprivate var infoLabel: UILabel!

    var friends = [UserEntity]()

    var isLoading = false

    override func viewDidLoad() {

        super.viewDidLoad()

        self.loadContacts()

        self.configEventObserver()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableView datasource

extension ContactsViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as? ContactTableViewCell
        cell!.user = self.friends[indexPath.item]
        return cell!
    }
}

// MARK: - UITableView delegate

extension ContactsViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let vc = Util.createViewController(storyboardName: "Profile", id: "ProfileView") as? ProfileViewController

        vc!.user = self.friends[indexPath.item]

        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

// MARK: - Internal Methods

extension ContactsViewController {

    fileprivate func loadContacts() {

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
                self.appendRows(rows: friends.count)
            }
        }
    }

    // Append specific number of rows on table view
    fileprivate func appendRows(rows: Int) {

        let firstIndex = self.friends.count - rows
        let lastIndex = self.friends.count

        var indexPathes = [IndexPath]()

        for index in firstIndex..<lastIndex {
            indexPathes.append(IndexPath(row: index, section: 0))
        }

        tableView.beginUpdates()
        tableView.insertRows(at: indexPathes, with: .fade)
        tableView.endUpdates()
    }
}

// MARK: - Event Observer

extension ContactsViewController {

    fileprivate func configEventObserver() {

        NotificationCenter.default.addObserver(self, selector: #selector(ContactsViewController.didAcceptInvitation(_:)), name: NSNotification.Name(rawValue: "didAcceptInvitation"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsViewController.didDeleteFriend(_:)), name: NSNotification.Name(rawValue: "didDeleteFriend"), object: me)

        // notification from background thread
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ContactsViewController.didMyFriendInvitationAccepted(_:)),
                                               name: NSNotification.Name(rawValue: "didMyFriendInvitationAccepted"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsViewController.didFriendBreak(_:)), name: NSNotification.Name(rawValue: "didFriendBreak"), object: me)
    }

    // This method is called for sync this view controller and accout model after accept invitation
    func didAcceptInvitation(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let friend = userInfo["userEntityOfNewFriend"] as? UserEntity else { return }

        // note the invitation data is referring the account model, but friends data is not.
        // so the account model already removed the accepted invitation, but the friends data
        // still need to be sync with account model manually
        self.friends.insert(friend, at: 0)

        // insert the friend data in table view
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .automatic)
        self.tableView.endUpdates()
    }

    // This method is called for sync this view controller and accout model after delete friend
    func didDeleteFriend(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let id = userInfo["idOfDeletedFriend"] as? String else { return }
        guard let index = self.friends.index(where: { $0.id == id }) else { return }

        // sync friends data with account model manually
        self.friends.remove(at: index)

        // update tableview, if the number of my invitation is zero, insert into section 1
        // otherwise, remove the corresponding row in section 0
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
        self.tableView.endUpdates()
    }

    // This method is called for sync this view controller and accout model after my friend invitation was accepted
    func didMyFriendInvitationAccepted(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let newFriend = userInfo["userEntityOfNewFriend"] as? UserEntity else { return }

        self.friends.insert(newFriend, at: 0)

        // this method is called from background thread (because it fired from notification center)
        // must switch to main thread for UI updating
        gcd.sync(.main) {

            // update tableview, insert the corresponding row in section 0
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        }
    }

    // This method is called for sync this view controller and accout model after someone dump me
    func didFriendBreak(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let brokenUserId = userInfo["userIdOfBrokenFriend"] as? String else { return }
        guard let index = self.friends.index(where: { $0.id == brokenUserId }) else { return }

        self.friends.remove(at: index)

        // this method is called from background thread (because it fired from notification center)
        // must switch to main thread for UI updating
        gcd.sync(.main) {

            // update tableview, delete the corresponding row from section 0
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        }
    }
}

// MARK: - ContactTableViewCell

final class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak fileprivate var avatarImageView: UIImageView!
    @IBOutlet weak fileprivate var nickNameLabel: UILabel!

    var user: UserEntity! {
        didSet { self.configDisplay() }
    }

    private func configDisplay() {

        if let photo = user.photo {
            self.avatarImageView.sd_setImage(with: URL(string: photo), placeholderImage: TomoConst.Image.DefaultAvatar)
        }

        self.nickNameLabel.text = user.nickName
    }
}
