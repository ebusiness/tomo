//
//  MyPostsViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class MyPostsViewController: MyAccountBaseController {
    
    let screenHeight = UIScreen.mainScreen().bounds.height
    let loadTriggerHeight = CGFloat(88.0)
    
    var posts = [AnyObject]()
    var oldestContent: AnyObject?
    var isLoading = false
    var isExhausted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let postCellNib = UINib(nibName: "ICYPostCell", bundle: nil)
        self.tableView.registerNib(postCellNib, forCellReuseIdentifier: "ICYPostCellIdentifier")
        
        let postImageCellNib = UINib(nibName: "ICYPostImageCell", bundle: nil)
        self.tableView.registerNib(postImageCellNib, forCellReuseIdentifier: "ICYPostImageCellIdentifier")
        
        self.clearsSelectionOnViewWillAppear = false
        
        self.registerForNotifications()
        
        loadMoreContent()
    }
    
}

// MARK: UITableView DataSource

extension MyPostsViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row] as! PostEntity
        post.owner = me
        
        var cell: ICYPostCell!
        
        if post.images?.count > 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("ICYPostImageCellIdentifier", forIndexPath: indexPath) as! ICYPostImageCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("ICYPostCellIdentifier", forIndexPath: indexPath) as! ICYPostCell
        }
        
        cell.post = post
        cell.delegate = self
        
        return cell
    }
}

// MARK: UITableView Delegate

extension MyPostsViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let vc = Util.createViewControllerWithIdentifier("PostView", storyboardName: "Home") as! PostViewController
        vc.post = posts[indexPath.row] as! PostEntity
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let content = posts.get(indexPath.row) as? PostEntity {
            
            if content.images?.count > 0 {
                return 334
            } else {
                return 131
            }
        }
        
        return UITableViewAutomaticDimension
    }
    
}

// MARK: UIScrollView Delegate

extension MyPostsViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        super.scrollViewDidScroll(scrollView)
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (contentHeight - screenHeight - loadTriggerHeight) < offsetY {
            loadMoreContent()
        }

    }
}

// MARK: Private methods

extension MyPostsViewController {
    
    private func loadMoreContent() {
        
        // skip if already in loading
        if isLoading || isExhausted {
            return
        }
        
        isLoading = true
        
        var params = Dictionary<String, AnyObject>()
        params["category"] = "mine"
        
        if let oldestContent = oldestContent as? PostEntity {
            params["before"] = oldestContent.createDate.timeIntervalSince1970
        }
        
        
        
        
        AlamofireController.request(.GET, "/posts", parameters: params, success: { result in
            
            let posts:[PostEntity]? = PostEntity.collection(result)
            
            if let loadPosts:[AnyObject] = posts {
                self.posts += loadPosts
                self.appendRows(loadPosts.count)
            } else {
                // the response is not post
            }
            self.isLoading = false
            
        }) { _ in
                
            self.isLoading = false
            self.isExhausted = true
        }
    }
    
    private func appendRows(rows: Int) {
        
        let firstIndex = posts.count - rows
        let lastIndex = posts.count
        
        var indexPathes = [NSIndexPath]()
        
        for index in firstIndex..<lastIndex {
            indexPathes.push(NSIndexPath(forRow: index, inSection: 0))
        }
        
        // hold the oldest content for pull-up loading
        oldestContent = posts.last
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPathes, withRowAnimation: UITableViewRowAnimation.Middle)
        tableView.endUpdates()
        
    }
}

// MARK: - NSNotificationCenter

extension MyPostsViewController {
    
    private func registerForNotifications() {
        ListenerEvent.PostLiked.addObserver(self, selector: Selector("receivePostLiked:"))
        ListenerEvent.PostCommented.addObserver(self, selector: Selector("receivePostCommented:"))
        ListenerEvent.PostBookmarked.addObserver(self, selector: Selector("receivePostBookmarked:"))
    }
    
    private func receivePost(notification: NSNotification,done: (cell: ICYPostCell,user: UserEntity)->() ){
        
        if let userInfo = notification.userInfo {
            let json = JSON(userInfo)
            let postid = json["targetId"].stringValue
            let user = UserEntity(json["from"])
            
            let cell: AnyObject? = self.tableView.visibleCells().find { ($0 as! ICYPostCell).post?.id == postid }
            if let cell = cell as? ICYPostCell {
                gcd.sync(.Main) {
                    done(cell: cell, user: user)
                }
            }
        }
    }
    
    func receivePostLiked(notification: NSNotification) {
        self.receivePost(notification) { (cell, user) -> () in
            if let post = cell.post {
                post.like = post.like ?? []
                post.like!.append(user.id)
                
                cell.likeButton.bounce({ () -> Void in
                    cell.post = post
                })
            }
            
        }
    }
    
    func receivePostCommented(notification: NSNotification) {
        self.receivePost(notification) { (cell, _) -> () in
            
            cell.shake(nil)
        }
    }
    
    func receivePostBookmarked(notification: NSNotification) {
        self.receivePost(notification) { (cell, _) -> () in
            
            cell.collectionButton.tada(nil)
        }
    }
    
}
