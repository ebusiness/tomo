//
//  GroupDetailViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/09/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class GroupDetailViewController: UITableViewController {

    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet weak var joinButton: UIButton!

    @IBOutlet weak var loadingLabel: UILabel!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

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
        
        self.registerClosureForAccount()
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        // trigger on the position of one screen height to bottom
        if (contentHeight - TomoConst.UI.ScreenHeight) < offsetY {
            self.loadMorePosts()
        }

        self.configNavigationBarByScrollPosition()
    }

    override func viewWillDisappear(animated: Bool) {
        // restore the normal navigation bar before disappear
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewWillAppear(animated: Bool) {
        self.configNavigationBarByScrollPosition()
    }

}

// MARK: - Actions

extension GroupDetailViewController {
    
    @IBAction func joinGroup(sender: UIButton) {

        sender.userInteractionEnabled = false
        
        Router.Group.Join(id: self.group.id).response {
            if $0.result.isFailure {
                sender.userInteractionEnabled = true
                return
            } else {
                me.addGroup(self.group)
            }
        }
    }
    
    @IBAction func didCreatePost(segue: UIStoryboardSegue) {
        self.loadNewPost()
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
    }
    
    @IBAction func postButtonTapped(sender: UIBarButtonItem) {
        let postCreateViewController = Util.createViewControllerWithIdentifier("PostCreateView", storyboardName: "Home") as! CreatePostViewController
        postCreateViewController.group = self.group
        self.presentViewController(postCreateViewController, animated: true, completion: nil)
    }

    @IBAction func chatButtonTapped(sender: UIBarButtonItem) {
        let groupChatViewController = GroupChatViewController()
        groupChatViewController.group = self.group
        groupChatViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(groupChatViewController, animated: true)
    }

}

// MARK: - Navigation

extension GroupDetailViewController {
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
        if segue.identifier == "pushGroupDescription" {
            let destination = segue.destinationViewController as! GroupDescriptionViewController
            destination.group = group
        }
    }
}

// MARK: - UITableView datasource

extension GroupDetailViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let post = self.posts[indexPath.row]

        var cell: TextPostTableViewCell!

        // If the post has one or more images, use ImagePostTableViewCell, otherwise use the TextPostTableViewCell.
        if post.images?.count > 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("ImagePostCell") as! ImagePostTableViewCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("TextPostCell") as! TextPostTableViewCell
        }

        // Give the cell post data, this will tirgger configDisplay
        cell.post = post

        // Set current navigation controller as the cell's delegate,
        // for the navigation when post author's photo been tapped, etc.
        cell.delegate = self.navigationController

        return cell
    }
}

// MARK: - UITableView delegate

extension GroupDetailViewController {

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.rowHeights[indexPath.item]
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let postDetailVC = storyBoard.instantiateViewControllerWithIdentifier("PostDetailViewController") as! PostDetailViewController
        postDetailVC.post = self.posts[indexPath.row]
        navigationController?.pushViewController(postDetailVC, animated: true)
    }
}

// MARK: - Internal Methods

extension GroupDetailViewController {

    private func configDisplay() {

        self.joinButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.joinButton.layer.borderWidth = 2

        self.title = self.group.name
        self.coverImageView.sd_setImageWithURL(NSURL(string: group.cover), placeholderImage: DefaultGroupImage)

        // set the header view's size according the screen size
        self.tableView.tableHeaderView?.frame = CGRect(origin: CGPointZero, size: self.headerViewSize)

        guard let myGroups = me.groups else { return }

        if myGroups.contains(self.group.id) {
            _ = navigationItem.rightBarButtonItems?.map {
                $0.enabled = true
            }
            self.joinButton.hidden = true
        } else {
            _ = navigationItem.rightBarButtonItems?.map {
                $0.enabled = false
            }
            self.joinButton.hidden = false
        }
    }
    
    private func registerClosureForAccount() {
        
        me.addGroupsObserver { _ in
            if self.tabBarController?.selectedViewController?.childViewControllers.last is GroupDetailViewController {
                gcd.sync(.Main){
                    UIView.animateWithDuration(TomoConst.Duration.Short) {
                        self.configDisplay()
                    }
                }
            } else {
                gcd.sync(.Main){
                    self.configDisplay()
                }
            }
        }
    }
    
    // Fetch more post as use scroll down to the bottom of table view.
    private func loadMorePosts() {

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
                self.loadingLabel.hidden = false
                return
            }

            if let newPosts = PostEntity.collection($0.result.value!) as [PostEntity]? {

                // append new posts
                self.posts += newPosts

                // calculate the cell height for display these contents
                self.rowHeights += newPosts.map { self.simulateLayout($0) }

                // let table view display new contents
                self.appendRows(newPosts.count)
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
            if let loadPosts:[PostEntity] = PostEntity.collection($0.result.value!) {
                self.posts = loadPosts + self.posts
                self.rowHeights = loadPosts.map { self.simulateLayout($0) } + self.rowHeights
                self.prependRows(loadPosts.count)
            }
        }
    }

    // Append specific number of rows on table view
    private func appendRows(rows: Int) {

        let firstIndex = self.posts.count - rows
        let lastIndex = self.posts.count

        var indexPathes = [NSIndexPath]()

        for index in firstIndex..<lastIndex {
            indexPathes.push(NSIndexPath(forRow: index, inSection: 0))
        }

        // hold the oldest post for pull-up loading
        self.oldestPost = self.posts.last

        // hold the latest post for pull-down loading
        if firstIndex == 0 {
            self.latestPost = self.posts.first
        }

        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPathes, withRowAnimation: .Fade)
        tableView.endUpdates()
    }

    // Prepend specific number of rows on table view
    private func prependRows(rows: Int) {

        var indexPathes = [NSIndexPath]()

        for index in 0..<rows {
            indexPathes.push(NSIndexPath(forRow: index, inSection: 0))
        }

        // hold the latest content for pull-up loading
        self.latestPost = self.posts.first

        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPathes, withRowAnimation: .Fade)
        tableView.endUpdates()
    }

    // Calulate the cell height beforehand
    private func simulateLayout(post: PostEntity) -> CGFloat {

        let cell: TextPostTableViewCell

        if post.images?.count > 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("ImagePostCell") as! ImagePostTableViewCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("TextPostCell") as! TextPostTableViewCell
        }

        cell.post = post

        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        
        return size.height
    }

    private func configNavigationBarByScrollPosition() {

        let offsetY = self.tableView.contentOffset.y

        // begin fade in the navigation bar background at the point which is
        // twice height of topbar above the bottom of the table view header area.
        // and let the fade in complete just when the bottom of navigation bar
        // overlap with the bottom of table header view.
        if offsetY > self.headerHeight - TomoConst.UI.TopBarHeight * 2 {

            let distance = self.headerHeight - offsetY - TomoConst.UI.TopBarHeight * 2
            let image = Util.imageWithColor(0x0288D1, alpha: abs(distance) / TomoConst.UI.TopBarHeight)
            self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)

            // if user scroll down so the table header view got shown, just keep the navigation bar transparent
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        }
    }
}
