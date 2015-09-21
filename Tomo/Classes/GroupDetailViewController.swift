//
//  GroupDetailViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/09/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class GroupDetailViewController: BaseTableViewController {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var joinButton: UIButton!
    
    var group: GroupEntity!
    
    var posts: [PostEntity]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        
        tableView.registerNib(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        tableView.registerNib(UINib(nibName: "PostImageCell", bundle: nil), forCellReuseIdentifier: "PostImageCell")
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        loadPosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPosts() {
        AlamofireController.request(.GET, "/groups/\(group.id)/posts", parameters: nil, encoding: .JSON, success: { (object) -> () in
            self.posts = PostEntity.collection(object)
            println(object)
            self.tableView.reloadData()
            }) { (_) -> () in
                
        }
    }
    
    deinit {
        println("group detail view controller released")
    }
    
}

// MARK: - Internal Methods

extension GroupDetailViewController {
    
    private func updateUI() {
        
        let postButton = UIBarButtonItem(image: UIImage(named: "create_new"), style: .Plain, target: self, action: "createPost")
        self.navigationItem.rightBarButtonItem = postButton
        
        self.title = group.name
        self.coverImageView.sd_setImageWithURL(NSURL(string: group.cover), placeholderImage: DefaultGroupImage)
        
        if let myGroups = me.groups {
            if myGroups.contains(self.group.id) {
                navigationItem.rightBarButtonItem?.enabled = true
                self.joinButton.hidden = true
            } else {
                navigationItem.rightBarButtonItem?.enabled = false
                joinButton.hidden = false
            }
        }
    }
}

// MARK: - Actions

extension GroupDetailViewController {
    
    @IBAction func joinGroup(sender: UIButton) {
        
        sender.userInteractionEnabled = false
        AlamofireController.request(.PATCH, "/groups/\(self.group.id)/join", success: { _ in
            me.groups?.append(self.group.id)
            self.updateUI()
            }) { err in
                sender.userInteractionEnabled = true
        }
    }
    
    func createPost() {
        let postCreateView = Util.createViewControllerWithIdentifier("PostCreateView", storyboardName: "Home") as! CreatePostViewController
        postCreateView.group = self.group
        self.showViewController(postCreateView, sender: self)
    }
}

// MARK: - Navigation

extension GroupDetailViewController {
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - TableView
extension GroupDetailViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let posts = posts {
            return posts.count
        } else {
            return 0
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: PostCell!
        
        let post = posts![indexPath.row]
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
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts![indexPath.row]
        var textHeight = 0
        
        if post.content.length > 150 {
            // one character take 18 points height,
            // and 150 characters will take 7 rows
            textHeight = 18 * 7
        } else {
            // one row have 24 characters
            textHeight = post.content.length / 24 * 18
        }
        
        if post.images?.count > 0 {
            return CGFloat(472 + textHeight)
        } else {
            return CGFloat(108 + textHeight)
        }
    }
}
