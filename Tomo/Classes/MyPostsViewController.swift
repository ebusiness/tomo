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
        
        var postCellNib = UINib(nibName: "PostCell", bundle: nil)
        self.tableView.registerNib(postCellNib, forCellReuseIdentifier: "PostCell")
        
        var postImageCellNib = UINib(nibName: "PostImageCell", bundle: nil)
        self.tableView.registerNib(postImageCellNib, forCellReuseIdentifier: "PostImageCell")
        
        self.clearsSelectionOnViewWillAppear = false
        
        self.registerForNotifications()
        
        loadMoreContent()
    }
    
    override func setupMapping() {
        
        let postMapping = RKObjectMapping(forClass: PostEntity.self)
        postMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "contentText": "content",
            "coordinate": "coordinate",
            "images_mobile.name": "images",
            "like": "like",
            "createDate": "createDate"
            ])
        
        let responseDescriptor = RKResponseDescriptor(mapping: postMapping, method: .GET, pathPattern: "/posts", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        
        manager.addResponseDescriptor(responseDescriptor)
        
    }
    
}

// MARK: UITableView DataSource

extension MyPostsViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var post = posts[indexPath.row] as! PostEntity
        post.owner = me
        
        var cell: PostCell!
        
        if post.images?.count > 0 {
            
            cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell", forIndexPath: indexPath) as! PostImageCell
            
            let subviews = (cell as! PostImageCell).scrollView.subviews
            
            for subview in subviews {
                subview.removeFromSuperview()
            }
            
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        }
        
        cell.post = post
        cell.setupDisplay()
        
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
        
        var params = Dictionary<String, NSTimeInterval>()
        
        if let oldestContent = oldestContent as? PostEntity {
            params["before"] = oldestContent.createDate.timeIntervalSince1970
        }
        
        manager.getObjectsAtPath("/posts", parameters: params, success: { (operation, result) -> Void in
            
            self.posts += result.array()
            self.appendRows(Int(result.count))
            
            self.isLoading = false
            }) { (operation, err) -> Void in
                println(err)
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
        SocketController.sharedInstance.addObserverForEvent(self, selector: Selector("receivePostLiked:"), event: .PostLiked)
        SocketController.sharedInstance.addObserverForEvent(self, selector: Selector("receivePostCommented:"), event: .PostCommented)
        SocketController.sharedInstance.addObserverForEvent(self, selector: Selector("receivePostBookmarked:"), event: .PostBookmarked)
    }
    
    private func receivePost(notification: NSNotification,done: (cell: PostCell,nickName: String)->() ){
        
        if let userInfo = notification.userInfo {
            let json = JSON(userInfo)
            let postid = json["targetPost"]["_id"].stringValue
            let nickName = json["_from"]["nickName"].stringValue
            
            let cell: AnyObject? = self.tableView.visibleCells().find { ($0 as! PostCell).post.id == postid }
            if let cell = cell as? PostCell {
                cell.post.like = json["targetPost"]["like"].arrayObject as? [String]
                gcd.sync(.Main, closure: { () -> () in
                    done(cell: cell, nickName: nickName)
                })
            }
        }

    }
    
    func receivePostLiked(notification: NSNotification) {
        self.receivePost(notification) { (cell, nickName) -> () in
            
            cell.likeButton.bounce({ () -> Void in
                cell.setupDisplay()
            })
            Util.showInfo("\(nickName)赞了您的帖子")
        }
    }
    
    func receivePostCommented(notification: NSNotification) {
        self.receivePost(notification) { (cell, nickName) -> () in
            
            cell.shake(nil)
            Util.showInfo("\(nickName)评论了您的帖子")
        }
    }
    
    func receivePostBookmarked(notification: NSNotification) {
        self.receivePost(notification) { (cell, nickName) -> () in
            
            cell.bookmarkButton.tada(nil)
            Util.showInfo("\(nickName)收藏了您的帖子")
        }
    }
    
}
