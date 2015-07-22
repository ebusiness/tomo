//
//  UserPostsViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class UserPostsViewController: ProfileBaseController {
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var postCellNib = UINib(nibName: "PostCell", bundle: nil)
        self.tableView.registerNib(postCellNib, forCellReuseIdentifier: "PostCell")
        
        var postImageCellNib = UINib(nibName: "PostImageCell", bundle: nil)
        self.tableView.registerNib(postImageCellNib, forCellReuseIdentifier: "PostImageCell")
        
        ApiController.getPostOfUser(self.user.id!) { (posts, _) -> Void in
            if let posts = posts {
                self.posts = posts
                self.tableView.reloadData()
            }
        }
    }
    
}

extension UserPostsViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var post = self.posts[indexPath.row]
        var cell: PostCell!
        
        if post.imagesmobile.count > 0 {
            
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

extension UserPostsViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PostCell
        
        let vc = Util.createViewControllerWithIdentifier("PostView", storyboardName: "Home") as! PostViewController
        vc.post = cell.post
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
