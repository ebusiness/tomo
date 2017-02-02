//
//  FriendListSendRequestController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


import UIKit

final class FriendListSendRequestController: UITableViewController {

    @IBOutlet weak var loadingLabel: UILabel!

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    var invitedUsers = [UserEntity]()

    var oldestContent: UserEntity?

    var isLoading = false
    var isExhausted = false

    override func viewDidLoad() {

        super.viewDidLoad()

        self.loadMoreContent()
    }
}

// MARK: - UITableView DataSource

extension FriendListSendRequestController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.invitedUsers.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let user = self.invitedUsers[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? RequestFriendCell
        cell!.user = user
        
        return cell!
    }
}

// MARK: - UITableView Delegate

extension FriendListSendRequestController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = Util.createViewControllerWithIdentifier(id: "ProfileView", storyboardName: "Profile") as? ProfileViewController
        vc!.user = self.invitedUsers[indexPath.row]
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

// MARK: UIScrollView Delegate

extension FriendListSendRequestController {

    // Fetch more contents when scroll down to bottom
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        // trigger on the position of one screen height to bottom
        if (contentHeight - TomoConst.UI.ScreenHeight) < offsetY {
            self.loadMoreContent()
        }
    }
}

// MARK: - Actions

extension FriendListSendRequestController {

    @IBAction func searchFriend(_ sender: Any) {
        let vc = Util.createViewControllerWithIdentifier(id: "SearchFriend", storyboardName: "Contacts")
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: - Internal Methods

extension FriendListSendRequestController {

    fileprivate func loadMoreContent() {

        // skip if already in loading or no more contents
        if self.isLoading || self.isExhausted {
            return
        }

        self.isLoading = true

        Router.Invitation.Find.response {

            // Mark as exhausted when something wrong (probably 404)
            if $0.result.isFailure {
                self.isLoading = false
                self.isExhausted = true
                self.loadingIndicator.stopAnimating()
                self.loadingLabel.isHidden = false
                return
            }

            if let result:[UserEntity] = UserEntity.collection($0.result.value!) {

                // append new contents
                self.invitedUsers += result

                // let table view display new contents
                self.appendRows(rows: result.count)
            }

            self.isLoading = false
        }
    }

    // Append specific number of rows on table view
    private func appendRows(rows: Int) {

        let firstIndex = self.invitedUsers.count - rows
        let lastIndex = self.invitedUsers.count

        var indexPathes = [IndexPath]()

        for index in firstIndex..<lastIndex {
            indexPathes.append(IndexPath(row: index, section: 0))
        }

        // hold the oldest content for pull-up loading
        oldestContent = self.invitedUsers.last

        tableView.beginUpdates()
        tableView.insertRows(at: indexPathes, with: .middle)
        tableView.endUpdates()

    }
}

// MARK: - RequestFriendCell

final class RequestFriendCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var bioLabel: UILabel!

    var user: UserEntity! {

        didSet {

            if let photo = user.photo {
                self.avatarImageView.sd_setImage(with: URL(string: photo), placeholderImage: defaultAvatarImage)
            }

            self.userNameLabel.text = user.nickName
            self.bioLabel.text = user.bio
        }
    }
}

