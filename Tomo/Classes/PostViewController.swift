//
//  PostViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/14.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostViewController : BaseViewController{
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var commentInput: UITextView!
    @IBOutlet weak var postImageList: UIScrollView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var commentTableView: UITableView!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var likedBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    
    @IBOutlet weak var commentVerticalSpace: NSLayoutConstraint!
    @IBOutlet weak var commentInputViewHeight: NSLayoutConstraint!
    
    var commentContent: String?
    var cellForHeight: CommentCell!
    
    var post: Post! {
        didSet {
            if let headerView = headerView {
                updateUIForHeader()
            }
        }
    }
    
    var comments: [Comments] {
        get {
            return post.comments.array as! [Comments]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "詳細"
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.layer.masksToBounds = true
        
        Util.changeImageColorForButton(likedBtn,color: UIColor.redColor())
        let color = Util.UIColorFromRGB(0xFF007AFF, alpha: 1)
        Util.changeImageColorForButton(commentBtn,color: color)
        Util.changeImageColorForButton(shareBtn,color: color)
        Util.changeImageColorForButton(deleteBtn,color: color)
        
        commentInput.layer.borderColor = UIColor.grayColor().CGColor
        commentInput.layer.borderWidth = 0.5
        commentInput.layer.cornerRadius = 5
        deleteBtn.hidden = !post.isMyPost
        
        updateUIForHeader()
        
        self.setImageList()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("postWasDeleted:"), name: SVProgressHUDDidDisappearNotification, object: nil)
        
    }
    
    // MARK:HeaderView - @IBAction
    
    @IBAction func commentBtnTapped(sender: AnyObject) {
        commentInput.becomeFirstResponder()
    }
    
    @IBAction func avatarImageTapped(sender: UITapGestureRecognizer) {
        let vc = Util.createViewControllerWithIdentifier("AccountEditViewController", storyboardName: "Setting") as! AccountEditViewController
        vc.user = post.owner
        vc.readOnlyMode = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func postImageViewTapped(sender: UITapGestureRecognizer) {
        println("postImageViewTapped")
    }
    
    @IBAction func likeBtnTapped(sender: AnyObject) {
        println("likeBtnTapped")
    }
    
    @IBAction func shareBtnTapped(sender: AnyObject) {
        
        let shareUrl = kAPIBaseURLString + "/mobile/share/post/" + self.post.id!
        
        var shareImage:UIImage?
        if let imageView = self.postImageList.subviews[0] as? UIImageView {
            shareImage = imageView.image!
        }
        
        Util.alertActionSheet(self, optionalDict: [
            "微信":{ (_) -> Void in
                    OpenidController.instance.wxShare(0, img: shareImage, description: self.post.content!, url:shareUrl)
                },
            "朋友圈":{ (_) -> Void in
                OpenidController.instance.wxShare(1, img: shareImage, description: self.post.content!, url: shareUrl)
            
                }
            ])

    }
    
    @IBAction func deleteBtnTapped(sender: UIButton) {
        
        Util.alertActionSheet(self, optionalDict: ["削除しますか？":{ (_) -> Void in
            ApiController.postDelete(self.post.id!, done: { (error) -> Void in
            })
            
            self.post.delete()
            self.navigationController?.popViewControllerAnimated(true)
        }])
        
    }
    
    @IBAction func tableViewTapped(sender: UITapGestureRecognizer) {
        self.commentInput.resignFirstResponder()
    }
    
    @IBAction func sendCommentBtnTapped(sender: AnyObject) {
        Util.showHUD()
        
        ApiController.addComment(self.post.id!, content: commentContent!) { (error) -> Void in
            Util.dismissHUD()
            
            if let error = error {
                Util.showError(error)
            } else {
                self.refreshPostDetail()
            }
            
            self.commentInput.resignFirstResponder()
            self.commentInput.text = ""
        }

    }
}

// MARK:HeaderView - Action

extension PostViewController {

    func updateUIForHeader(){
        if let photo_ref = post.owner?.photo_ref {
            avatarImageView.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
        }
        
        userName.text = post.owner?.nickName
        timeLabel.text = Util.displayDate(post.createDate)
        
        contentLabel.text = post.content
        
        commentBtn.setTitle("\(post.comments.count)", forState: .Normal)
        likedBtn.setTitle("\(post.liked.count)", forState: .Normal)

        contentLabel.preferredMaxLayoutWidth = self.headerView.frame.size.width - 2 * 16
        let size = self.headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) as CGSize
        
        self.headerView.frame.size.height = size.height
    }
    
    
    func setImageList(){
        
//        for imageview in postImageList.subviews {
//            imageview.removeFromSuperview()
//        }
        if post.imagesmobile.count < 1 {
            //hide [postImageList] when imagesmobile.count
            postImageList.addConstraint(NSLayoutConstraint(item: postImageList, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0))
            return
        }
        
        var listViewHeight:CGFloat = 250
        postImageList.addConstraint(NSLayoutConstraint(item: postImageList, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: listViewHeight))
        
        let lv = postImageList.frame.size.width / listViewHeight
        
        var scrollWidth:CGFloat = 0
        
        for i in 0..<post.imagesmobile.count{
            
            if let image = post.imagesmobile[i] as? Images{
                let imgView = UIImageView(frame: CGRectZero )
                imgView.setImageWithURL(NSURL(string: image.name! ), completed: { (image, error, cacheType, url) -> Void in
                    }, usingActivityIndicatorStyle: .Gray)
                
                postImageList.addSubview(imgView)
                imgView.setTranslatesAutoresizingMaskIntoConstraints(false)
                
                var width:CGFloat = postImageList.frame.size.width
                
                if let w = image.width as? CGFloat,h=image.height as? CGFloat{
                    
                    if  (w / h) > lv{
                        width = w > postImageList.frame.size.width ? postImageList.frame.size.width : w
                    }else{
                        width = w / h * (h > listViewHeight ? listViewHeight : h)
                    }
                }
                
                imgView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: width))
                
                postImageList.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Height, relatedBy: .Equal, toItem: postImageList, attribute: .Height, multiplier: 1.0, constant: 0))
                
                postImageList.addConstraint(NSLayoutConstraint(item: imgView, attribute: .CenterY, relatedBy: .Equal, toItem: postImageList, attribute: .CenterY, multiplier: 1.0, constant: 0))
                
                postImageList.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Leading, relatedBy: .Equal, toItem: postImageList, attribute: .Leading, multiplier: 1.0, constant: scrollWidth ))
                
                
                scrollWidth += width + 5
            }
            
        }
        
        postImageList.contentSize.width = scrollWidth
    }
    
    
    func refreshPostDetail(){
        
        ApiController.getPost(post.id!, done: { (error) -> Void in
            if error == nil {
                self.post = DBController.postById(self.post.id!)
                self.commentTableView.reloadData()
            } else {
                Util.showInfo("この投稿が削除されました。")
                self.post.delete()
            }
        })
    }

    
}


extension PostViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        let comment = comments[indexPath.row]
        cell.comment = comment
        cell.parentVC = self
        
        return cell
    }
    
}

extension PostViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if cellForHeight == nil {
            cellForHeight = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
        }
        
        return cellForHeight.height(comments[indexPath.row], width: tableView.bounds.width)
    }
    
}


// MARK:CommentInputView - Action

extension PostViewController {
    
    // MARK: - Notification
    
    func keyboardWillShow(notification: NSNotification) {
        if let dic = notification.userInfo {
            if let keyboardFrame = dic[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() {
                if let duration = dic[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                    self.commentInput.superview?.hidden = false
                    self.commentVerticalSpace.constant = keyboardFrame.height - 49 //tabbar -> 49
                    
                    UIView.animateWithDuration(duration, animations: { () -> Void in
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
    func keyboardDidHide(notification: NSNotification) {
        if let dic = notification.userInfo {
            if let duration = dic[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                self.commentVerticalSpace.constant = 0
                
                UIView.animateWithDuration(duration, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    self.commentInput.superview?.hidden = true
                })
            }
        }
    }
}


extension PostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        if commentContent == nil || commentContent!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if commentContent == nil || commentContent!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            textView.text = "评论:"
            textView.textColor = UIColor.lightGrayColor()
        }
        

    }
    
    func textViewDidChange(textView: UITextView) {
        commentContent = textView.text
        if commentContent != nil && commentContent!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            sendBtn.enabled = true
        } else {
            sendBtn.enabled = false
        }
        if let superView = textView.superview {
            let viewheight = (textView.contentSize.height + 2 * 8)
            commentInputViewHeight.constant = viewheight > 48 ? (viewheight < 201 ? viewheight : 200 ) : 48
        }
    }
}