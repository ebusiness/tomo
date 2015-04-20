//
//  PostDetailViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/06.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostDetailViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var headerView: PostDetailHeaderView!
    
    var cellForHeight: CommentCell!
    
    var postId: String!
    var post: Post! {
        return DBController.postById(postId)
    }
    
    var comments: [Comments] {
        get {
            return post.comments.array as! [Comments]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = Util.createViewWithNibName("PostDetailHeaderView") as! PostDetailHeaderView
        
        headerView.viewWidth = view.bounds.width
        
        headerView.delegate = self
        
        headerView.post = self.post

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ApiController.getPost(postId, done: { (error) -> Void in
            if error == nil {
                self.headerView.post = self.post
                self.tableView.reloadData()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueCommentInput" {
            let vc = segue.destinationViewController as! CommentInputViewController
            vc.postId = post.id!
        }
    }

}

extension PostDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        
        cell.comment = comments[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerView.viewHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if cellForHeight == nil {
            cellForHeight = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
        }
        
        return cellForHeight.height(comments[indexPath.row], width: tableView.bounds.width)
    }
}

extension PostDetailViewController: PostDetailHeaderViewDelegate {
    
    func commentBtnTapped() {
        performSegueWithIdentifier("SegueCommentInput", sender: nil)
    }
}
