//
//  PostViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/14.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostViewController: BaseViewController{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postImageList: UIScrollView!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var commentInputView: UIView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentFooterLabel: UILabel!
    
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var likedBtn: UIButton!
    @IBOutlet weak var bookmarkBtn: UIButton!
    
    @IBOutlet weak var commentInputViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerConstraint: NSLayoutConstraint!
    
    var isKeyboardShown: Bool = false
    
    var isCommentInitial = false
    var initialImageIndex: Int?
    
    var listViewHeight:CGFloat = UIScreen.mainScreen().bounds.size.height * 0.618 //  250
    let profileHeaderHeight:CGFloat = 100
    
    var commentContent: String?
    var cellForHeight: CommentCell!
    
    let commentBackgroundView = UIView()
    
    var post: PostEntity! {
        didSet {
            if nil != avatarImageView {
                updateUIForHeader()
            }
        }
    }
    
    var comments: [CommentEntity]? {
        get {
            return post.comments
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alwaysShowNavigationBar = ( self.post.images?.count ?? 0 ) < 1
        self.postImageList.scrollsToTop = false
        self.headerHeight = self.listViewHeight - 64
        
        self.setViewsLayer()
        
        self.hideSendBtn(true)
        
        gcd.async(.Main) { // fix deadlock
            Util.changeImageColorForButton(self.commentBtn,color: UIColor.whiteColor())
            Util.changeImageColorForButton(self.likedBtn,color: UIColor.redColor())
            Util.changeImageColorForButton(self.bookmarkBtn,color: UIColor.orangeColor())
        }
        
        self.setPostContent()
        self.updateUIForHeader()
        
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if isCommentInitial {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
            isCommentInitial = false
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        if scrollView == self.postImageList && !pageControl.hidden && scrollView.subviews.count > 2{
            
            let page = scrollView.contentOffset.x / scrollView.frame.size.width
            if page == 0 {
                changeImageTo(scrollView.subviews[0].tag)
            } else if page == 2 {
                changeImageTo(scrollView.subviews[2].tag)
            }
            pageControl.currentPage = scrollView.subviews[1].tag
            
        }
    }
    
    @IBAction func avatarImageTapped(sender: UITapGestureRecognizer) {
        
        let profileViewController = navigationController?.childViewControllers.find { $0 is ProfileViewController } as? ProfileViewController
        
        if let profileViewController = profileViewController {
            navigationController?.popToViewController(profileViewController, animated: true)
        } else {
            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
            vc.user = post.owner
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func likeBtnTapped(sender: UIButton) {
        sender.userInteractionEnabled = false
        AlamofireController.request(.PATCH, "/posts/\(self.post.id)/like", success: { _ in
            
            if let like = self.post.like {
                like.contains(me.id) ? self.post.like!.remove(me.id) : self.post.like!.append(me.id)
            } else {
                self.post.like = [me.id]
            }
            
            self.likedBtn.bounce {
                self.updateUIForHeader()
                sender.userInteractionEnabled = true
            }
            
            }) { _ in
                sender.userInteractionEnabled = true
        }
    }
    
    @IBAction func bookmarkBtnTapped(sender: UIButton) {
        sender.userInteractionEnabled = false
        AlamofireController.request(.PATCH, "/posts/\(self.post.id)/bookmark",
            success: { _ in
                
                self.post.bookmark = self.post.bookmark ?? []
                
                if self.post.bookmark!.contains(me.id) {
                    self.post.bookmark!.remove(me.id)
                } else {
                    self.post.bookmark!.append(me.id)
                }
                
                self.updateUIForHeader()
                self.bookmarkBtn.tada {
                    sender.userInteractionEnabled = true
                }
            }) { _ in
                sender.userInteractionEnabled = true
        }
    }
    
    @IBAction func moreBtnTapped(sender: AnyObject) {
        
//        let shareUrl = kAPIBaseURLString + "/mobile/share/post/" + self.post.id!
        
        var shareImage:UIImage?
        if self.postImageList.subviews.count > 0 {
            if let imageView = self.postImageList.subviews[0] as? UIImageView {
                shareImage = imageView.image
            }
        }
        
        
        var optionalList = Dictionary<String,((UIAlertAction!) -> Void)!>()
        
        optionalList["微信"] = { (_) -> Void in
            OpenidController.instance.wxShare(0, img: shareImage, description: self.post.content!, extInfo: self.post.id)
        }
        
        optionalList["朋友圈"] = { (_) -> Void in
            OpenidController.instance.wxShare(1, img: shareImage, description: self.post.content!, extInfo: self.post.id)
        }
        
        if post.owner.id != me.id {
            optionalList["举报此内容"] = { (_) -> Void in
                
                Util.alert(self, title: "举报此内容", message: "您确定要举报此内容吗？", action: { (action) -> Void in
                    AlamofireController.request(.POST, "/reports/posts/\(self.post.id)", success: { _ in
                        Util.showInfo("举报信息已发送")
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                })
            }
        }
        
        if post.owner.id == me.id {
            optionalList["删除"] = { (_) -> Void in
                
                Util.alert(self, title: "删除帖子", message: "确定删除该帖子吗？", action: { (action) -> Void in
                    AlamofireController.request(.DELETE, "/posts/\(self.post.id)", success: { _ in
                        Util.showInfo("帖子已删除")
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                })
            }
        }
        
        Util.alertActionSheet(self, optionalDict: optionalList)
        
    }
    
    @IBAction func tableViewTapped(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func sendCommentBtnTapped(sender: AnyObject) {
        
        var param = Dictionary<String, String>();
        param["content"] = commentContent;
        //        param["replyTo"] = "552220aa915a1dd84834731b";//コメントID
        
        self.commentContent = nil
        self.commentTextView.text = "评论:"
        self.commentTextView.textColor = UIColor.lightGrayColor()
        commentInputViewConstraint.constant = 50
        
        self.hideSendBtn(true)
        self.view.endEditing(true)
        
        AlamofireController.request(.POST, "/posts/\(self.post.id)/comments", parameters: param, success: { result in
            
            let comment = CommentEntity()
            comment.owner = me
            comment.content = param["content"]
            comment.createDate = NSDate()
            
            if self.comments == nil { self.post.comments = [] }
            self.post.comments?.append(comment)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .Automatic)
            
        })
        
    }
}

// MARK:HeaderView - Action

extension PostViewController {
    
    private func setViewsLayer() {
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.layer.masksToBounds = true
        
        commentBtn.layer.cornerRadius = commentBtn.frame.size.width / 2
        commentBtn.backgroundColor = Util.UIColorFromRGB(NavigationBarColorHex, alpha: 1)
        commentBtn.superview?.bringSubviewToFront(commentBtn)
        
        let topLayer = CALayer()
        topLayer.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 0.5)
        topLayer.backgroundColor = UIColor.lightGrayColor().CGColor
        commentInputView.layer.addSublayer(topLayer)
    }
    
    func setPostContent(){
        if let photo = self.post.owner.photo {
            avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
        }
        
        userName.text = self.post.owner.nickName
        timeLabel.text = post.createDate.relativeTimeToString()
        
        let imageCount = self.post.images?.count ?? 0
        
        if imageCount > 0 {
            self.setImageList()
        }
        pageControl.numberOfPages = imageCount
        pageControl.hidden = imageCount < 2
        
        let para = NSMutableParagraphStyle()
        para.minimumLineHeight = 30
        
        let attributeString = NSAttributedString(string: post.content, attributes: [
            NSParagraphStyleAttributeName: para
            ])
        
        contentLabel.attributedText = attributeString
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        let dateString = dateFormatter.stringFromDate(post.createDate)
        contentFooterLabel.text = dateString
        
        self.contentLabel.bounds.size.width = UIScreen.mainScreen().bounds.size.width - 16 * 2
        let contentSize = self.contentLabel.sizeThatFits(self.contentLabel.bounds.size)
        
        let headerView = self.tableView.tableHeaderView as UIView!
        //        headerView.frame.size.width = UIScreen.mainScreen().bounds.size.width
        
        let contentFooterHeight: CGFloat = 16.0 + 22.0
        let contentHeight = self.profileHeaderHeight + contentSize.height + contentFooterHeight + 8 * 2
        if ( self.post.images?.count ?? 0 ) < 1 {
            self.postImageList.hidden = true
            headerView.frame.size.height = contentHeight
        } else {
            headerView.frame.size.height = contentHeight + self.listViewHeight
        }
        
        self.tableView.tableHeaderView = headerView
        self.headerConstraint.constant = contentHeight
        self.tableView.layoutIfNeeded()
    }
    
    func updateUIForHeader(){
        
        if let like = self.post.like where like.count > 0 {
            likedBtn.setTitle("\(like.count)", forState: .Normal)
        } else {
            likedBtn.setTitle("", forState: .Normal)
        }
        
        let likeimage = ( self.post.like ?? [] ).contains(me.id) ? "hearts_filled" : "hearts"
        if let image = UIImage(named: likeimage) {
            
            let image = Util.coloredImage(image, color: UIColor.redColor())
            likedBtn?.setImage(image, forState: .Normal)
            
        }
        
        let bookmarkimage = ( self.post.bookmark ?? [] ).contains(me.id) ? "star_filled" : "star"
        
        if let image = UIImage(named: bookmarkimage) {
            
            let image = Util.coloredImage(image, color: UIColor.orangeColor())
            bookmarkBtn?.setImage(image, forState: .Normal)
            
        }
    }
    
    func adjustContentMode(imgView: UIImageView, image: UIImage!) {
        if image == nil {
            imgView.contentMode = .ScaleAspectFill
            return
        }
        let size = image.size
        let ratio = size.width / size.height
        if size.height < (self.listViewHeight / ICYCollectionViewSingleImageCell.minCenterScale)
            && size.width < (UIScreen.mainScreen().bounds.width / ICYCollectionViewSingleImageCell.minCenterScale) {
                imgView.contentMode = .Center
                
        } else if ratio > ICYCollectionViewSingleImageCell.maxAspectFitScale
            || ratio < ICYCollectionViewSingleImageCell.minAspectFitScale {
                imgView.contentMode = .ScaleAspectFit
        }else {
            imgView.contentMode = .ScaleAspectFill
        }
    }
    
    func getImageView(index: Int) -> UIImageView {
        if  let images = post.images {
            
            let i = index > images.count ? index - images.count : index < 0 ? images.count + index : index
            
            let imgView = UIImageView(frame: CGRectZero )
            imgView.setImageWithURL(NSURL(string: images[i] ),
                completed: {(image, _, _, _)-> Void in
                    self.adjustContentMode(imgView, image: image)
                },
                usingActivityIndicatorStyle: .Gray)
            imgView.userInteractionEnabled = true
            imgView.tag = i
            let tap = UITapGestureRecognizer(target: self, action: Selector("postImageViewTapped:"))
            imgView.addGestureRecognizer(tap)
            imgView.translatesAutoresizingMaskIntoConstraints = false
//            imgView.contentMode = UIViewContentMode.ScaleAspectFill
            imgView.clipsToBounds = true
            return imgView
        }
        return UIImageView()
        
    }
    
    func setImageList(){
        
        for imageview in postImageList.subviews {
            imageview.removeFromSuperview()
        }
        
        let imageWidth = UIScreen.mainScreen().bounds.size.width
        
        let centerImageView = getImageView (0)
        var views = ["centerImageView": centerImageView, "postImageList": postImageList]
        postImageList.addSubview(centerImageView)
        
        var constraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[centerImageView(==postImageList)]", options: [], metrics: nil, views: views)
        
        if (post.images?.count ?? 0 ) == 1 {
            postImageList.contentSize.width = imageWidth
            constraint += NSLayoutConstraint.constraintsWithVisualFormat("H:|[centerImageView(==postImageList)]|", options: .AlignAllCenterX , metrics: nil, views: views)
        } else {
            postImageList.contentSize.width = imageWidth * 3
            
            let leftImageView = getImageView (-1)
            let rightImageView = getImageView (1)
            
            postImageList.insertSubview(leftImageView, atIndex: 0)
            postImageList.addSubview(rightImageView)
            
            views["leftImageView"] = leftImageView
            views["rightImageView"] = rightImageView
            
            constraint += NSLayoutConstraint.constraintsWithVisualFormat("H:|[leftImageView(==centerImageView)][centerImageView(==imageWidth)][rightImageView(==centerImageView)]", options: [.AlignAllTop, .AlignAllBottom], metrics: ["imageWidth": imageWidth], views: views)
            postImageList.contentOffset.x = imageWidth
        }
        postImageList.addConstraints(constraint)
        
        if let initialImageIndex = initialImageIndex {
            changeImageTo(initialImageIndex)
        }
    }
    
    func changeImageTo(index: Int){
        if let images = post.images where postImageList.subviews.count == 3 {
            let left = postImageList.subviews[0] as! UIImageView
            let center = postImageList.subviews[1] as! UIImageView
            let right = postImageList.subviews[2] as! UIImageView
            
            left.tag = index == 0 ? images.count - 1 : index - 1
            center.tag = index
            right.tag = index == (images.count - 1) ? 0 : index + 1
            
            left.setImageWithURL(NSURL(string: images[left.tag] ), completed: {(image, _, _, _)-> Void in
                self.adjustContentMode(left, image: image)
                }, usingActivityIndicatorStyle: .Gray)
            center.setImageWithURL(NSURL(string: images[center.tag] ), completed: {(image, _, _, _)-> Void in
                self.adjustContentMode(center, image: image)
                }, usingActivityIndicatorStyle: .Gray)
            right.setImageWithURL(NSURL(string: images[right.tag] ), completed: {(image, _, _, _)-> Void in
                self.adjustContentMode(right, image: image)
                }, usingActivityIndicatorStyle: .Gray)
            
            postImageList.contentOffset.x = UIScreen.mainScreen().bounds.size.width//postImageList.frame.size.width
        }
    }
    
    func postImageViewTapped(sender: UITapGestureRecognizer) {
        if isKeyboardShown {
            self.view.endEditing(true)
            return
        }
        if let images = post.images, imageView = sender.view as? UIImageView where postImageList.subviews.count > 0 && images.count > 0 {
            
            var items = [MHGalleryItem]();
            
            if postImageList.subviews.count == 1 {
                let image =  (postImageList.subviews.first as! UIImageView).image
                items.append(MHGalleryItem(image: image))
            } else {
                let left =  (postImageList.subviews.first as! UIImageView)
                let center =  (postImageList.subviews[1] as! UIImageView)
                let right =  (postImageList.subviews.last as! UIImageView)
                
                for i in 0..<images.count {
                    if i == left.tag {
                        items.append(self.getGalleryItem(i, image: left.image))
                    } else if i == center.tag {
                        items.append(self.getGalleryItem(i, image: center.image))
                    } else if i == right.tag {
                        items.append(self.getGalleryItem(i, image: right.image))
                    } else {
                        items.append(MHGalleryItem(URL: images[i], galleryType: .Image))
                    }
                }
            }
            
            let gallery = MHGalleryController(presentationStyle: MHGalleryViewMode.ImageViewerNavigationBarShown)
            gallery.galleryItems = items
            gallery.presentationIndex = imageView.tag
            
            //            if post.images?.count == 1 {
            gallery.presentingFromImageView = imageView
            //            }
            
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
    
    private func getGalleryItem(index: Int, image: UIImage?) -> MHGalleryItem {
        if let image = image {
            return MHGalleryItem(image: image)
        } else if let images = post.images where images.count > index {
            return MHGalleryItem(URL: images[index], galleryType: .Image)
        } else {
            return MHGalleryItem(image: UIImage(named: "file_broken")!)
        }
    }
    
}


extension PostViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        let index = self.comments!.count - indexPath.row - 1
        cell.comment = self.comments![index]
        cell.parentVC = self
        
        return cell
    }
    
}

extension PostViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if cellForHeight == nil {
            cellForHeight = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
        }
        
        let index = self.comments!.count - indexPath.row - 1
        return cellForHeight.height(self.comments![index], width: tableView.bounds.width)
    }
    
}

extension PostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        if commentContent == nil || commentContent!.length == 0 {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if commentContent == nil || commentContent!.length == 0 {
            textView.text = "评论:"
            textView.textColor = UIColor.lightGrayColor()
            self.hideSendBtn(true)
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        
        let viewheight = textView.contentSize.height + 2 * 8
        commentInputViewConstraint.constant = viewheight < 50 ? 50 : viewheight > 100 ? 100 : viewheight
        
        if textView.markedTextRange == nil {
            commentContent = textView.text.trimmed()
            
            if commentContent!.length > 0 {
                
                self.hideSendBtn(false)
            } else {
                
                self.hideSendBtn(true)
            }
        }
    }
}


extension PostViewController {
    
    func hideSendBtn(hidden: Bool){
        if (self.commentBtn.transform.a == 1) != hidden {
            return
        }
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            if hidden {
                self.commentBtn.transform = CGAffineTransformMakeScale(0, 0)
            } else {
                self.commentBtn.transform = CGAffineTransformMakeScale(1, 1)
            }
            self.navigationController?.view.layoutIfNeeded()
        })
    }
}
// MARK - NSNotificationCenter
extension PostViewController {
    
    private func registerForKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        isKeyboardShown = true
        if let info = notification.userInfo, keyboardHeight = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height ,duration = info[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval {
            
            self.bottomConstraint.constant = keyboardHeight
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
            
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        isKeyboardShown = false
        if let info = notification.userInfo, duration = info[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval {
            
            self.bottomConstraint.constant = 0
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
}
