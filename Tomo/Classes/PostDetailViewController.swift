//
//  PostDetailViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/06.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var headerView: PostDetailHeaderView!
//    @IBOutlet weak var avatarImageView: UIImageView!
//    @IBOutlet weak var avatarImageView: UIImageView!
//    @IBOutlet weak var avatarImageView: UIImageView!
    
    var cellForHeight: CommentCell!
    
    var post: Post!
    var imageSize: CGSize!
    
    var comments: [Comments] {
        get {
            return post.sortedComments()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        headerView = Util.createViewWithNibName("PostDetailHeaderView") as PostDetailHeaderView
        headerView.viewWidth = view.bounds.width
        headerView.imageSize = imageSize
        headerView.post = post
//        postImageViewHeightConstraint.constant = imageSize.height / imageSize.width * view.bounds.width

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PostDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as CommentCell
        
        cell.comment = comments[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerView.viewHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
}
