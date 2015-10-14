//
//  UserPostsViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class UserPostsViewController: ProfileBaseController {
    
    let screenHeight = UIScreen.mainScreen().bounds.height
    let loadTriggerHeight = CGFloat(88.0)
    
    var posts = [PostEntity]()
    var oldestContent: PostEntity?
    var isLoading = false
    var isExhausted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var postCellNib = UINib(nibName: "ICYPostCell", bundle: nil)
        self.tableView.registerNib(postCellNib, forCellReuseIdentifier: "ICYPostCellIdentifier")
        
        var postImageCellNib = UINib(nibName: "ICYPostImageCell", bundle: nil)
        self.tableView.registerNib(postImageCellNib, forCellReuseIdentifier: "ICYPostImageCellIdentifier")
        
        self.clearsSelectionOnViewWillAppear = false
        
        loadMoreContent()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let vc = segue.destinationViewController as? ProfileHeaderViewController {
            
            vc.photoImageViewTapped = { (sender)->() in
                
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
}

// MARK: UITableView DataSource

extension UserPostsViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        post.owner = self.user
        
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

extension UserPostsViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let vc = Util.createViewControllerWithIdentifier("PostView", storyboardName: "Home") as! PostViewController
        vc.post = posts[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let content = posts.get(indexPath.row) {
            
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

extension UserPostsViewController {
    
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

extension UserPostsViewController {
    
    private func loadMoreContent() {
        
        // skip if already in loading
        if isLoading || isExhausted {
            return
        }
        
        isLoading = true
        
        var params = Dictionary<String, NSTimeInterval>()
        
        if let oldestContent = oldestContent {
            params["before"] = oldestContent.createDate.timeIntervalSince1970
        }
        
        AlamofireController.request(.GET, "/users/\(self.user.id)/posts", parameters: params, success: { results in
            
            if let loadPosts:[PostEntity] = PostEntity.collection(results) {
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

