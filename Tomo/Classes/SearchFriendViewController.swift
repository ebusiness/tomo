//
//  SearchFriendViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class SearchFriendViewController: UITableViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var searchResultLabel: UILabel!

    var users = [UserEntity]()

    var isLoading = false
    var isExhausted = false

    var page = 0

    // String hold the search text
    var searchText: String?

    // Search bar, design it in stroyBoard looks ugly, have to make it by code
    lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.delegate = self
        bar.placeholder = "检索用户名"
        return bar
    }()

    override func viewDidLoad() {

        super.viewDidLoad()

        // attach the search bar on navigation bar
        self.navigationItem.titleView = self.searchBar
    }

    @IBAction func closeButtonTapped(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - UITableView datasource

extension SearchFriendViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("SearchFriendCell", forIndexPath: indexPath) as! SearchFriendCell
        cell.user = self.users[indexPath.row]
        return cell
    }
}

// MARK: - UITableView delegate

extension SearchFriendViewController {

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = self.users[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension SearchFriendViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        guard let text = self.searchBar.text where text.trimmed().length > 0 else { return }

        // do nothing if the search word didn't change
        guard self.searchText != text else { return }

        // resign first responder so the keyboard disappear
        searchBar.resignFirstResponder()

        self.isLoading = true

        self.startActivityIndicator()

        // hold the search text
        self.searchText = text

        // reset page number
        self.page = 0

        // reset exhausted flag
        self.isExhausted = false

        // scroll to top for new result, check the zero contents case
        if self.users.count > 0 {
            let firstItemIndex = NSIndexPath(forItem: 0, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(firstItemIndex, atScrollPosition: .Top, animated: true)
        }

        // prepare for remove all current cell for new result
        var removeIndex: [NSIndexPath] = []
        for _ in self.users {
            removeIndex.append(NSIndexPath(forItem: removeIndex.count, inSection: 0))
        }

        // reset content
        self.users = [UserEntity]()
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths(removeIndex, withRowAnimation: .Automatic)
        self.tableView.endUpdates()

        Router.User.FindByNickName(nickName: text).response {

            if $0.result.isFailure {
                self.isLoading = false
                self.isExhausted = true
                self.stopActivityIndicator("没有找到与“\(self.searchText!)”相关的结果")
                return
            }

            if let users: [UserEntity] = UserEntity.collection($0.result.value!) {
                self.users = users
                self.appendCells(users.count)
                self.page++
            }

            self.isLoading = false
        }
    }
}

// MARK: - Internal Methods

extension SearchFriendViewController {

    private func startActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.searchResultLabel.alpha = 0
    }

    private func stopActivityIndicator(withString: String) {
        self.activityIndicator.stopAnimating()
        self.searchResultLabel.text = withString
        UIView.animateWithDuration(TomoConst.Duration.Short) {
            self.searchResultLabel.alpha = 1.0
        }
    }

    private func appendCells(count: Int) {

        let startIndex = self.users.count - count
        let endIndex = self.users.count

        var indexPaths = [NSIndexPath]()

        for i in startIndex..<endIndex {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            indexPaths.append(indexPath)
        }

        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        self.tableView.endUpdates()
    }
}

class SearchFriendCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var bioLabel: UILabel!

    var user: UserEntity! {
        didSet {

            if let photo = user.photo {
                self.avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
            }

            self.userNameLabel.text = user.nickName
            self.bioLabel.text = user.bio ?? ""
        }
    }
}
