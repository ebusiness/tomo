//
//  PostViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/14.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostViewController : BaseTableViewController{

    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var commentInput: UITextView!
    @IBOutlet weak var postImageList: UIScrollView!
    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var likedBtn: UIButton!
    @IBOutlet weak var bookmarkBtn: UIButton!

    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    let listViewHeight:CGFloat = 250
    let contentViewInitialHeight:CGFloat = 230

    var commentContent: String?
    var cellForHeight: CommentCell!

    var post: Post! {
        didSet {
            if let avatarImageView = avatarImageView {
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
        Util.changeImageColorForButton(bookmarkBtn,color: color)
        
        commentInput.layer.borderColor = UIColor.grayColor().CGColor
        commentInput.layer.borderWidth = 0.5
        commentInput.layer.cornerRadius = 5
        
        updateUIForHeader()
        
        if post.imagesmobile.count > 0 {
            
            self.setImageList()
            self.headerHeight = self.listViewHeight
            
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if post.imagesmobile.count < 1 {
            self.extendedLayoutIncludesOpaqueBars = false
            self.automaticallyAdjustsScrollViewInsets = true
            var image = Util.imageWithColor(0x673AB7, alpha: 1)
            self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
            
            self.tableView.tableHeaderView?.frame.size.height = self.contentViewHeight.constant
        }
    }
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if post.imagesmobile.count > 0 {
            super.scrollViewDidScroll(scrollView)
        }
    }
    
    @IBAction func avatarImageTapped(sender: UITapGestureRecognizer) {
        
        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = post.owner
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

    @IBAction func likeBtnTapped(sender: AnyObject) {
        ApiController.postLike(post.id!, done: { (error) -> Void in
            self.updateUIForHeader()
        })
    }

    @IBAction func bookmarkBtnTapped(sender: AnyObject) {
        ApiController.postBookmark(post.id!, done: { (error) -> Void in
            self.updateUIForHeader()
        })
    }

    
    @IBAction func moreBtnTapped(sender: AnyObject) {
        
        let shareUrl = kAPIBaseURLString + "/mobile/share/post/" + self.post.id!
        
        var shareImage:UIImage?
        if self.postImageList.subviews.count > 0 {
            if let imageView = self.postImageList.subviews[0] as? UIImageView {
                shareImage = imageView.image!
            }
        }
        
        
        var optionalList = Dictionary<String,((UIAlertAction!) -> Void)!>()
        
        optionalList["微信"] = { (_) -> Void in
            OpenidController.instance.wxShare(0, img: shareImage, description: self.post.content!, url:shareUrl)
        }
        
        optionalList["朋友圈"] = { (_) -> Void in
            OpenidController.instance.wxShare(1, img: shareImage, description: self.post.content!, url:shareUrl)
        }
        
        if post.isMyPost {
            optionalList["删除"] = { (_) -> Void in
                
                Util.alert(self, title: "删除帖子", message: "确定删除该帖子么?", action: { (action) -> Void in
                    ApiController.postDelete(self.post.id!, done: { (error) -> Void in
                    })
                    
                    self.post.delete()
                    Util.showInfo("帖子已删除")
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }
        }

        Util.alertActionSheet(self, optionalDict: optionalList)

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
        
        likedBtn.setTitle("\(post.liked.count)", forState: .Normal)
        bookmarkBtn.setTitle("\(post.bookmarked.count)", forState: .Normal)

        if let me = DBController.myUser() {
            
            let likeimage = me.liked_posts.containsObject(post) ? "hearts_filled" : "hearts"
            if let image = UIImage(named: likeimage) {
                
                let image = Util.coloredImage(image, color: UIColor.redColor())
                likedBtn?.setImage(image, forState: .Normal)
                
            }
            
            let bookmarkimage = me.bookmarked_posts.containsObject(post) ? "star_filled" : "star"
            if let image = UIImage(named: bookmarkimage) {
                
                let image = Util.coloredImage(image, color: UIColor.orangeColor())
                bookmarkBtn?.setImage(image, forState: .Normal)
                
            }
            
        }
        
        if let tableHeaderView = self.tableView.tableHeaderView
            where contentViewHeight.constant == self.contentViewInitialHeight {
            let contentSize = self.contentLabel.sizeThatFits(self.contentLabel.bounds.size)
            let heightChange = contentSize.height - self.contentLabel.frame.size.height
            
            contentViewHeight.constant = self.contentViewInitialHeight + heightChange
    
            tableHeaderView.frame.size.height = tableHeaderView.frame.size.height + heightChange
        }
        
    }
    
    func setImageList(){
        
        for imageview in postImageList.subviews {
            imageview.removeFromSuperview()
        }
        
        let imageWidth = self.listViewHeight / 3 * 4
        self.tableView.tableHeaderView?.frame.size.height = contentViewHeight.constant + self.listViewHeight

        var scrollWidth:CGFloat = 0
        
        for i in 0..<post.imagesmobile.count{
            
            if let image = post.imagesmobile[i] as? Images{
                let imgView = UIImageView(frame: CGRectZero )
                imgView.setImageWithURL(NSURL(string: image.name! ), completed: { (image, error, cacheType, url) -> Void in
                    }, usingActivityIndicatorStyle: .Gray)
                
                imgView.userInteractionEnabled = true
                
                let tap = UITapGestureRecognizer(target: self, action: Selector("postImageViewTapped:"))
                imgView.addGestureRecognizer(tap)
                imgView.setTranslatesAutoresizingMaskIntoConstraints(false)
                imgView.contentMode = UIViewContentMode.ScaleAspectFill
                imgView.clipsToBounds = true
                
                postImageList.addSubview(imgView)
                
                postImageList.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Height, relatedBy: .Equal, toItem: postImageList, attribute: .Height, multiplier: 1.0, constant: 0))
                postImageList.addConstraint(NSLayoutConstraint(item: imgView, attribute: .CenterY, relatedBy: .Equal, toItem: postImageList, attribute: .CenterY, multiplier: 1.0, constant: 0))
                
                if post.imagesmobile.count == 1 {
                    
                    postImageList.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Leading, relatedBy: .Equal, toItem: postImageList, attribute: .Leading, multiplier: 1.0, constant: 0 ))
                    postImageList.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Trailing, relatedBy: .Equal, toItem: postImageList, attribute: .Trailing, multiplier: 1.0, constant: 0 ))
                    postImageList.addConstraint(NSLayoutConstraint(item: imgView, attribute: .CenterX, relatedBy: .Equal, toItem: postImageList, attribute: .CenterX, multiplier: 1.0, constant: 0 ))
                    
                } else {
                    
                    imgView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: imageWidth))
                    postImageList.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Leading, relatedBy: .Equal, toItem: postImageList, attribute: .Leading, multiplier: 1.0, constant: scrollWidth ))
                    
                    scrollWidth += 5
                }
                scrollWidth += imageWidth
            }
            
        }
        
        postImageList.contentSize.width = scrollWidth
    }

    func postImageViewTapped(sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView,image = imageView.image {
            
            var items = [MHGalleryItem]();
            var index = 0
            for i in 0..postImageList.subviews.count {
                if let item = postImageList.subviews[i] as? UIImageView,image = item.image {
                    if imageView == item {
                        index = i
                    }
                    items.append(MHGalleryItem(image: image))
                }
            }
            
            let gallery = MHGalleryController(presentationStyle: MHGalleryViewMode.ImageViewerNavigationBarShown)
            gallery.galleryItems = items
            gallery.presentationIndex = index
            
            if post.imagesmobile.count == 1 {
                gallery.presentingFromImageView = imageView
            }
            
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
    
    func refreshPostDetail(){
        
        ApiController.getPost(post.id!, done: { (error) -> Void in
            if error == nil {
                self.post = DBController.postById(self.post.id!)
                self.tableView.reloadData()
            } else {
                Util.showInfo("この投稿が削除されました。")
                self.post.delete()
                self.navigationController?.popViewControllerAnimated(true)
            }
        })
    }

    
}


extension PostViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.comments.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        let index = post.comments.count - indexPath.row - 1
        let comment = comments[index ]
        cell.comment = comment
        cell.parentVC = self
        
        return cell
    }
    
}

extension PostViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if cellForHeight == nil {
            cellForHeight = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
        }
        
        let index = post.comments.count - indexPath.row - 1
        return cellForHeight.height(comments[index], width: tableView.bounds.width)
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
        }
    }
}
