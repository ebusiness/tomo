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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var postCellNib = UINib(nibName: "PostCell", bundle: nil)
        self.tableView.registerNib(postCellNib, forCellReuseIdentifier: "PostCell")
        
        var postImageCellNib = UINib(nibName: "PostImageCell", bundle: nil)
        self.tableView.registerNib(postImageCellNib, forCellReuseIdentifier: "PostImageCell")
        
//        tableView.backgroundView = UIImageView(image: UIImage(named: "pattern"))
        
        loadMoreContent()
    }
    
    override func setupMapping() {
        
        let userMapping = RKObjectMapping(forClass: UserEntity.self)
        userMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "nickName": "nickName",
            "photo_ref": "photo"
            ])
        
        let postMapping = RKObjectMapping(forClass: PostEntity.self)
        postMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "contentText": "content",
            "images_mobile.name": "images",
            "like": "like",
            "createDate": "createDate"
            ])
        
        let ownerRelationshipMapping = RKRelationshipMapping(fromKeyPath: "_owner", toKeyPath: "owner", withMapping: userMapping)
        postMapping.addPropertyMapping(ownerRelationshipMapping)
        
        let responseDescriptor = RKResponseDescriptor(mapping: postMapping, method: .GET, pathPattern: "/bookmark", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        
        manager.addResponseDescriptor(responseDescriptor)
        
    }
}

// MARK: UITableView DataSource

extension BookmarkedPostsViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var post = bookmarks[indexPath.row] as! PostEntity
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
        if isLoading {
            return
        }
        
        isLoading = true
        
        var params = Dictionary<String, NSTimeInterval>()
        
        if let oldestContent = oldestContent as? PostEntity {
            params["before"] = oldestContent.createDate.timeIntervalSince1970
        }
        
        manager.getObjectsAtPath("/bookmark", parameters: params, success: { (operation, result) -> Void in
            
            self.bookmarks += result.array()
            self.appendRows(Int(result.count))
            
            self.isLoading = false
            }) { (operation, err) -> Void in
                println(err)
                self.isLoading = false
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