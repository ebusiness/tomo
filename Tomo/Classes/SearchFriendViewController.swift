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

    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableView datasource

extension SearchFriendViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchFriendCell", for: indexPath) as? SearchFriendCell
        cell?.user = self.users[indexPath.row]
        return cell!
    }
}

// MARK: - UITableView delegate

extension SearchFriendViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let vc = Util.createViewControllerWithIdentifier(id: "ProfileView", storyboardName: "Profile") as? ProfileViewController
        vc?.user = self.users[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension SearchFriendViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        guard let text = self.searchBar.text, !text.trimmed().isEmpty else { return }

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
        if !self.users.isEmpty {
            let firstItemIndex = IndexPath(item: 0, section: 0)
            self.tableView.scrollToRow(at: firstItemIndex, at: .top, animated: true)
        }

        // prepare for remove all current cell for new result
        var removeIndex: [IndexPath] = []
        for _ in self.users {
            removeIndex.append(IndexPath(item: removeIndex.count, section: 0))
        }

        // reset content
        self.users = [UserEntity]()
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: removeIndex, with: .automatic)
        self.tableView.endUpdates()

        Router.User.FindByNickName(nickName: text).response {

            if $0.result.isFailure {
                self.isLoading = false
                self.isExhausted = true
                self.stopActivityIndicator(withString: "没有找到与“\(self.searchText!)”相关的结果")
                return
            }

            if let users: [UserEntity] = UserEntity.collection($0.result.value!) {
                self.users = users
                self.appendCells(count: users.count)
                self.page+=1
            }

            self.isLoading = false
        }
    }
}

// MARK: - Internal Methods

extension SearchFriendViewController {

    fileprivate func startActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.searchResultLabel.alpha = 0
    }

    fileprivate func stopActivityIndicator(withString: String) {
        self.activityIndicator.stopAnimating()
        self.searchResultLabel.text = withString
        UIView.animate(withDuration: TomoConst.Duration.Short) {
            self.searchResultLabel.alpha = 1.0
        }
    }

    fileprivate func appendCells(count: Int) {

        let startIndex = self.users.count - count
        let endIndex = self.users.count

        var indexPaths = [IndexPath]()

        for i in startIndex..<endIndex {
            let indexPath = IndexPath(item: i, section: 0)
            indexPaths.append(indexPath)
        }

        self.tableView.beginUpdates()
        self.tableView.insertRows(at: indexPaths, with: .automatic)
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
                self.avatarImageView.sd_setImage(with: URL(string: photo), placeholderImage: defaultAvatarImage)
            }

            self.userNameLabel.text = user.nickName
            self.bioLabel.text = user.bio ?? ""
        }
    }
}
