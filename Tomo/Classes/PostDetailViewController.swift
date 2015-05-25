//
//  PostDetailViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/06.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

let PostDeletedString = "この投稿が削除されました。"

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
        
        navigationItem.title = "詳細"
        
        headerView = Util.createViewWithNibName("PostDetailHeaderView") as! PostDetailHeaderView
        
        headerView.viewWidth = view.bounds.width
        
        headerView.delegate = self
        
        headerView.post = self.post
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("postWasDeleted:"), name: SVProgressHUDDidDisappearNotification, object: nil)
        
        ApiController.getPost(postId, done: { (error) -> Void in
            if error == nil {
                self.headerView.post = self.post
                self.tableView.reloadData()
            } else {
                Util.showInfo(PostDeletedString)
                self.post.delete()
            }
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Notification
    
    func postWasDeleted(noti: NSNotification) {
        if let userinfo = noti.userInfo where (userinfo[SVProgressHUDStatusUserInfoKey] as? String) == PostDeletedString {
            navigationController?.popViewControllerAnimated(true)
        }
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

// MARK: - PostDetailHeaderViewDelegate

extension PostDetailViewController: PostDetailHeaderViewDelegate {
    
    func commentBtnTapped() {
        performSegueWithIdentifier("SegueCommentInput", sender: nil)
    }
    
    func avatarImageTapped() {
        let vc = Util.createViewControllerWithIdentifier("AccountEditViewController", storyboardName: "Setting") as! AccountEditViewController
        vc.user = post.owner
        vc.readOnlyMode = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func imageViewTapped(imageView: UIImageView) {
        showGalleryView(imageView)
    }
    
    func showGalleryView(imageView: UIImageView) {
        if let image = imageView.image {
            let item = MHGalleryItem(image: image)
            let gallery = MHGalleryController(presentationStyle: MHGalleryViewMode.ImageViewerNavigationBarShown)
            gallery.galleryItems = [item]
            gallery.presentingFromImageView = imageView
            
            gallery.UICustomization.useCustomBackButtonImageOnImageViewer = false
            gallery.UICustomization.showOverView = false
            gallery.UICustomization.showMHShareViewInsteadOfActivityViewController = false
            
            gallery.finishedCallback = { (currentIndex, image, transition, viewMode) -> Void in
                gcd.async(.Main, closure: { () -> () in
                    gallery.dismissViewControllerAnimated(true, dismissImageView: imageView, completion: { () -> Void in
                    })
                    
                })
            }
            
            presentMHGalleryController(gallery, animated: true, completion: nil)
        }
	}
	
    func shareBtnTapped(){
        let share = Util.createViewControllerWithIdentifier("share", storyboardName: "ActionSheet") as! ShareViewController
        share.share_description = self.post.content!
        share.share_image = headerView.postImageView.image
        share.share_url = kAPIBaseURLString + "/mobile/share/post/" + self.post.id!;
        Util.showActionSheet(self, vc: share)
    }
    
    func deleteBtnTapped() {
        let acvc = Util.createViewControllerWithIdentifier("AlertConfirmView", storyboardName: "ActionSheet") as! AlertConfirmViewController
        
        acvc.show(self, content: "削除しますか？", action: { () -> () in
            ApiController.postDelete(self.post.id!, done: { (error) -> Void in
            })
            
            self.post.delete()
            self.navigationController?.popViewControllerAnimated(true)
        })
    }
}
