//
//  GroupDetailViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/09/17.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit

final class GroupDetailViewController: UITableViewController {

    @IBOutlet weak fileprivate var coverImageView: UIImageView!

    @IBOutlet weak fileprivate var joinButton: UIButton!

    @IBOutlet weak fileprivate var loadingLabel: UILabel!

    @IBOutlet weak fileprivate var loadingIndicator: UIActivityIndicatorView!

    // The group entity
    var group: GroupEntity!

    // Array holds all post entities
    var posts = [PostEntity]()

    // Array holds all cell heights
    var rowHeights = [CGFloat]()

    var latestPost: PostEntity?
    var oldestPost: PostEntity?

    var isLoading = false
    var isExhausted = false

    let headerHeight = TomoConst.UI.ScreenHeight * 0.382
    let headerViewSize = CGSize(width: TomoConst.UI.ScreenWidth, height: TomoConst.UI.ScreenHeight * 0.382)

    override func viewDidLoad() {

        super.viewDidLoad()

        self.configDisplay()

        self.loadMorePosts()

        self.configEventObserver()
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        // trigger on the position of one screen height to bottom
        if (contentHeight - TomoConst.UI.ScreenHeight) < offsetY {
            self.loadMorePosts()
        }

        self.configNavigationBarByScrollPosition()
    }

    override func viewWillDisappear(_ animated: Bool) {
        // restore the normal navigation bar before disappear
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        self.configNavigationBarByScrollPosition()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Actions

extension GroupDetailViewController {

    @IBAction func joinGroup(_ sender: UIButton) {

        sender.isUserInteractionEnabled = false

        Router.Group.Join(id: self.group.id).response {
            if $0.result.isFailure {
                sender.isUserInteractionEnabled = true
                return
            } else {
                me.joinGroup(group: self.group)
            }
        }
    }

    @IBAction func didCreatePost(_ segue: UIStoryboardSegue) {
        self.loadNewPost()
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }

    @IBAction func postButtonTapped(_ sender: UIBarButtonItem) {
        let postCreateViewController = Util.createViewControllerWithIdentifier(id: "PostCreateView", storyboardName: "Home") as? CreatePostViewController
        postCreateViewController?.group = self.group
        self.present(postCreateViewController!, animated: true, completion: nil)
    }

    @IBAction func chatButtonTapped(_ sender: UIBarButtonItem) {
//        let groupChatViewController = ChatViewController()
//        groupChatViewController.group = self.group
//        groupChatViewController.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(groupChatViewController, animated: true)
        
        self.performSegue(withIdentifier: "SegueToChat", sender: self.group)
    }

}

// MARK: - Navigation

extension GroupDetailViewController {
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "pushGroupDescription" {
            let destination = segue.destination as? GroupDescriptionViewController
            destination?.group = group
        }

        if segue.identifier == "SegueToChat" {
            let chatVC = segue.destination as? ChatViewController
            chatVC?.group = sender as? GroupEntity
            chatVC?.hidesBottomBarWhenPushed = true
        }
    }
}

// MARK: - UITableView datasource

extension GroupDetailViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let post = self.posts[indexPath.row]

        var cell: TextPostTableViewCell!

        // If the post has one or more images, use ImagePostTableViewCell, otherwise use the TextPostTableViewCell.
        if (post.images?.count)! > 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ImagePostCell") as? ImagePostTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "TextPostCell") as? TextPostTableViewCell
        }

        // Give the cell post data, this will tirgger configDisplay
        cell!.post = post

        // Set current navigation controller as the cell's delegate,
        // for the navigation when post author's photo been tapped, etc.
        cell!.delegate = self.navigationController

        return cell!
    }
}

// MARK: - UITableView delegate

extension GroupDetailViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeights[indexPath.item]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let postDetailVC = storyBoard.instantiateViewController(withIdentifier: "PostDetailViewController") as? PostDetailViewController
        postDetailVC?.post = self.posts[indexPath.row]
        navigationController?.pushViewController(postDetailVC!, animated: true)
    }
}

// MARK: - Event Observer

extension GroupDetailViewController {

    fileprivate func configEventObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(GroupDetailViewController.didJoinGroup(_:)), name: NSNotification.Name(rawValue: "didJoinGroup"), object: me)
        NotificationCenter.default.addObserver(self, selector: #selector(GroupDetailViewController.didLeaveGroup(_:)), name: NSNotification.Name(rawValue: "didLeaveGroup"), object: me)
    }

    func didJoinGroup(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let group = userInfo["groupEntityOfNewGroup"] as? GroupEntity else { return }
        guard group.id == self.group.id else { return }

        // reconfig display
        self.configDisplay()
    }

    func didLeaveGroup(_ notification: NSNotification) {

        // ensure the data needed
        guard let userInfo = notification.userInfo else { return }
        guard let groupId = userInfo["idOfDeletedGroup"] as? String else { return }
        guard groupId == self.group.id else { return }

        // reconfig display
        self.configDisplay()
    }
}

// MARK: - Internal Methods

extension GroupDetailViewController {

    fileprivate func configDisplay() {

        self.joinButton.layer.borderColor = UIColor.white.cgColor
        self.joinButton.layer.borderWidth = 2

        self.title = self.group.name
        self.coverImageView.sd_setImage(with: URL(string: group.cover), placeholderImage: defaultGroupImage)

        // set the header view's size according the screen size
        self.tableView.tableHeaderView?.frame = CGRect(origin: CGPoint.zero, size: self.headerViewSize)

        guard let myGroups = me.groups else { return }

        if myGroups.contains(self.group.id) {
            _ = navigationItem.rightBarButtonItems?.map {
                $0.isEnabled = true
            }
            self.joinButton.isHidden = true
        } else {
            _ = navigationItem.rightBarButtonItems?.map {
                $0.isEnabled = false
            }
            self.joinButton.isHidden = false
        }
    }

    // Fetch more post as use scroll down to the bottom of table view.
    fileprivate func loadMorePosts() {

        // skip if already in loading or no more contents
        if self.isLoading || self.isExhausted {
            return
        }

        self.isLoading = true

        let postRouter = Router.Group.FindPosts(id: self.group.id, before: self.oldestPost?.createDate.timeIntervalSince1970)

        postRouter.response {

            // Mark as exhausted when something wrong (probably 404)
            if $0.result.isFailure {
                self.isLoading = false
                self.isExhausted = true
                self.loadingIndicator.stopAnimating()
                self.loadingLabel.isHidden = false
                return
            }

            if let newPosts = PostEntity.collection($0.result.value!) as [PostEntity]? {

                // append new posts
                self.posts += newPosts

                // calculate the cell height for display these contents
                self.rowHeights += newPosts.map { self.simulateLayout(post: $0) }

                // let table view display new contents
                self.appendRows(rows: newPosts.count)
            }

            self.isLoading = false
        }
    }

    // Fetch new posts
    func loadNewPost() {

        var parameters = Router.Post.FindParameters(category: .all)

        if let latestPost = self.latestPost {
            // TODO - This is a dirty solution
            parameters.after = latestPost.createDate.timeIntervalSince1970 + 1
        }

        Router.Post.Find(parameters: parameters).response {

            if $0.result.isFailure {
                return
            }

            // prepend new contents
            if let loadPosts: [PostEntity] = PostEntity.collection($0.result.value!) {
                self.posts = loadPosts + self.posts
                self.rowHeights = loadPosts.map { self.simulateLayout(post: $0) } + self.rowHeights
                self.prependRows(rows: loadPosts.count)
            }
        }
    }

    // Append specific number of rows on table view
    fileprivate func appendRows(rows: Int) {

        let firstIndex = self.posts.count - rows
        let lastIndex = self.posts.count

        var indexPathes = [IndexPath]()

        for index in firstIndex..<lastIndex {
            indexPathes.append(IndexPath(row: index, section: 0))
        }

        // hold the oldest post for pull-up loading
        self.oldestPost = self.posts.last

        // hold the latest post for pull-down loading
        if firstIndex == 0 {
            self.latestPost = self.posts.first
        }

        tableView.beginUpdates()
        tableView.insertRows(at: indexPathes, with: .fade)
        tableView.endUpdates()
    }

    // Prepend specific number of rows on table view
    fileprivate func prependRows(rows: Int) {

        var indexPathes = [IndexPath]()

        for index in 0..<rows {
            indexPathes.append(IndexPath(row: index, section: 0))
        }

        // hold the latest content for pull-up loading
        self.latestPost = self.posts.first

        tableView.beginUpdates()
        tableView.insertRows(at: indexPathes, with: .fade)
        tableView.endUpdates()
    }

    // Calulate the cell height beforehand
    fileprivate func simulateLayout(post: PostEntity) -> CGFloat {

        let cell: TextPostTableViewCell!

        if (post.images?.count)! > 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ImagePostCell") as? ImagePostTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "TextPostCell") as? TextPostTableViewCell
        }

        cell.post = post

        let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)

        return size.height
    }

    fileprivate func configNavigationBarByScrollPosition() {

        let offsetY = self.tableView.contentOffset.y

        // begin fade in the navigation bar background at the point which is
        // twice height of topbar above the bottom of the table view header area.
        // and let the fade in complete just when the bottom of navigation bar
        // overlap with the bottom of table header view.
        if offsetY > self.headerHeight - TomoConst.UI.TopBarHeight * 2 {

            let distance = self.headerHeight - offsetY - TomoConst.UI.TopBarHeight * 2
            let image = Util.imageWithColor(rgbValue: 0x0288D1, alpha: abs(distance) / TomoConst.UI.TopBarHeight)
            self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)

            // if user scroll down so the table header view got shown, just keep the navigation bar transparent
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
}
