//
//  BookmarkedPostsViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class BookmarkedPostsViewController: MyAccountBaseController {
    
    let screenHeight = UIScreen.mainScreen().bounds.height
    let loadTriggerHeight = CGFloat(88.0)
    
    var bookmarks = [AnyObject]()
    var oldestContent: AnyObject?
    var isLoading = false
    var isExhausted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let postCellNib = UINib(nibName: "ICYPostCell", bundle: nil)
        self.tableView.registerNib(postCellNib, forCellReuseIdentifier: "ICYPostCellIdentifier")
        
        let postImageCellNib = UINib(nibName: "ICYPostImageCell", bundle: nil)
        self.tableView.registerNib(postImageCellNib, forCellReuseIdentifier: "ICYPostImageCellIdentifier")
        
//        tableView.backgroundView = UIImageView(image: UIImage(named: "pattern"))
        
        loadMoreContent()
    }
}

// MARK: UITableView DataSource

extension BookmarkedPostsViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = bookmarks[indexPath.row] as! PostEntity
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

extension BookmarkedPostsViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let vc = Util.createViewControllerWithIdentifier("PostView", storyboardName: "Home") as! PostViewController
        vc.post = bookmarks[indexPath.row] as! PostEntity
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let content = bookmarks.get(indexPath.row) as? PostEntity {
            
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

extension BookmarkedPostsViewController {
    
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

extension BookmarkedPostsViewController {
    
    private func loadMoreContent() {
        
        // skip if already in loading
        if isLoading || isExhausted {
            return
        }
        
        isLoading = true
        
        var params = Dictionary<String, AnyObject>()
        params["category"] = "bookmark"
        
        if let oldestContent = oldestContent as? PostEntity {
            params["before"] = oldestContent.createDate.timeIntervalSince1970
        }
        
        AlamofireController.request(.GET, "/posts", parameters: params, success: { result in
            
            let posts:[PostEntity]? = PostEntity.collection(result)
            
            if let loadPosts:[AnyObject] = posts {
                self.bookmarks += loadPosts
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
        
        let firstIndex = bookmarks.count - rows
        let lastIndex = bookmarks.count
        
        var indexPathes = [NSIndexPath]()
        
        for index in firstIndex..<lastIndex {
            indexPathes.push(NSIndexPath(forRow: index, inSection: 0))
        }
        
        // hold the oldest content for pull-up loading
        oldestContent = bookmarks.last
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPathes, withRowAnimation: UITableViewRowAnimation.Middle)
        tableView.endUpdates()
        
    }
    
}