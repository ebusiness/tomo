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
    @IBOutlet weak var groupDescriptionButton: UIButton!
    
    var group: GroupEntity!
    
    var posts: [PostEntity]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        
        tableView.registerNib(UINib(nibName: "ICYPostCell", bundle: nil), forCellReuseIdentifier: "ICYPostCellIdentifier")
        tableView.registerNib(UINib(nibName: "ICYPostImageCell", bundle: nil), forCellReuseIdentifier: "ICYPostImageCellIdentifier")
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        groupDescriptionButton.setImage(Util.coloredImage(UIImage(named: "settings")!, color: UIColor.whiteColor()), forState: UIControlState.Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadPosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPosts() {
        AlamofireController.request(.GET, "/groups/\(group.id)/posts", parameters: nil, encoding: .JSON, success: { (object) -> () in
            self.posts = PostEntity.collection(object)
            self.tableView.reloadData()
            }) { (_) -> () in
                
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var contentInset = tableView.contentInset
        contentInset.bottom = 49.0
        tableView.contentInset = contentInset
        
        var scrollIndicatorInsets = tableView.scrollIndicatorInsets
        scrollIndicatorInsets.bottom = 49.0
        tableView.scrollIndicatorInsets = scrollIndicatorInsets
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
    
    @IBAction func addedPost(segue: UIStoryboardSegue) {
        // exit addPostView
    }
    
    func createPost() {
        let postCreateViewController = Util.createViewControllerWithIdentifier("PostCreateView", storyboardName: "Home") as! CreatePostViewController
        postCreateViewController.group = self.group
        self.presentViewController(postCreateViewController, animated: true, completion: nil)
    }
    
    @IBAction func groupDescriptionButtonPressed(sender: UIButton) {
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
        var cell: ICYPostCell!
        
        let post = posts![indexPath.row]
        if post.images?.count > 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("ICYPostImageCellIdentifier", forIndexPath: indexPath) as! ICYPostImageCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("ICYPostCellIdentifier", forIndexPath: indexPath) as! ICYPostCell
        }
        
        cell.post = post
        cell.delegate = self
        
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let post = posts![indexPath.row]
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let postDetailVC = storyBoard.instantiateViewControllerWithIdentifier("PostView") as! PostViewController
        postDetailVC.post = post
        navigationController?.pushViewController(postDetailVC, animated: true)
    }
}
