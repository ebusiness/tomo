//
//  PostDetailViewController.swift
//  Tomo
//
//  Created by ebuser on 2016/01/21.
//  Copyright © 2016年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class PostDetailViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var pageControl: UIPageControl!

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var likeButton: UIButton!

    @IBOutlet weak var bookmarkButton: UIButton!

    @IBOutlet weak var commentButton: UIButton!

    @IBOutlet weak var infoLabel: UILabel!

    @IBOutlet weak var commentTextView: UITextView!

    @IBOutlet weak var sendButton: UIButton!

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet var tableViewTapRecognizer: UITapGestureRecognizer!

    @IBOutlet weak var blurEffectView: UIVisualEffectView!

//    var headerView: UIView!
    let headerHeight = TomoConst.UI.ScreenHeight * 0.618
    let headerViewSize = CGSize(width: TomoConst.UI.ScreenWidth, height: TomoConst.UI.ScreenHeight * 0.618)
    let emptyHeaderViewSize = CGSize(width: TomoConst.UI.ScreenWidth, height: TomoConst.UI.TopBarHeight)

    var rowHeights = [CGFloat]()

    var post: PostEntity!

    var initialImageIndex: Int?

    var initialCommentIndex: Int?

    override func viewDidLoad() {

        super.viewDidLoad()

        // config the header view and navigation bar
        self.configDisplay()

        // calculate the row heights beforehand
        self.calculateRowHeight()

        // show how many likes, bookmarks, comments
        self.configInfoLabel()

        self.registerForKeyboardNotifications()
    }

    override func viewDidLayoutSubviews() {

        if let initialImageIndex = self.initialImageIndex {
            // TODO: here cause a warning, but it works for now
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: initialImageIndex, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: false)
        }

        if let initialCommentIndex = self.initialCommentIndex {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: initialCommentIndex, inSection: 0), atScrollPosition: .Top, animated: false)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        // restore the normal navigation bar before disappear
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewWillAppear(animated: Bool) {
        self.configNavigationBarByScrollPosition()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - Internal methods

extension PostDetailViewController {

    private func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }

    private func configDisplay() {

        // don't interrupt the scroll to top function of main scroll view
        self.collectionView.scrollsToTop = false
        self.commentTextView.scrollsToTop = false

        if let imageNumber = self.post.images?.count where imageNumber > 0 {

            if imageNumber > 1 {
                self.pageControl.numberOfPages = imageNumber
                self.pageControl.currentPage = 0
            } else {
                self.pageControl.hidden = true
            }

            // set the header view's size according the screen size
            self.tableView.tableHeaderView?.frame = CGRect(origin: CGPointZero, size: self.headerViewSize)

        } else {

            // set the header view's size as tall as the top bar
            self.tableView.tableHeaderView?.frame = CGRect(origin: CGPointZero, size: self.emptyHeaderViewSize)
        }

    }

    private func calculateRowHeight() {

        let authorInfoCell = self.tableView.dequeueReusableCellWithIdentifier("AuthorInfoCell") as! PostDisplayCell
        let contentCell = self.tableView.dequeueReusableCellWithIdentifier("ContentCell") as! PostDisplayCell

        authorInfoCell.post = self.post
        contentCell.post = self.post

        // calculate the author info cell
        let authorInfoCellSize = authorInfoCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)

        // calculate the content cell
        let contentCellSize = contentCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)

        self.rowHeights.push(authorInfoCellSize.height)
        self.rowHeights.push(contentCellSize.height)

        // calculate all the comment cells
        if let comments = self.post.comments {

            let commentCell = self.tableView.dequeueReusableCellWithIdentifier("CommentCell") as! PostCommentCell

            self.rowHeights.appendContentsOf(comments.reverse().map {
                commentCell.comment = $0
                let commentCellSize = commentCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                return commentCellSize.height
            })
        }
    }

    private func configInfoLabel() {

        var info = [String]()

        if let likes = post.like where likes.contains(me.id) {
            self.likeButton.setImage(TomoConst.Image.FilledHeart, forState: .Normal)
            info.push("\(likes.count)赞")
        } else {
            self.likeButton.setImage(TomoConst.Image.EmptyHeart, forState: .Normal)
        }

        if let bookmarks = post.bookmark where bookmarks.contains(me.id) {
            self.bookmarkButton.setImage(TomoConst.Image.FilledStar, forState: .Normal)
            info.push("\(bookmarks.count)收藏")
        } else {
            self.bookmarkButton.setImage(TomoConst.Image.EmptyStar, forState: .Normal)
        }

        if let comments = post.comments where comments.count > 0 {
            info.push("\(comments.count)评论")
        }

        if info.count > 0 {
            self.infoLabel.text = info.joinWithSeparator(" ")
        } else {
            self.infoLabel.text = nil
        }
    }

    func keyboardWillShow(notification: NSNotification) {
        guard
            let info = notification.userInfo,
            keyboardHeight = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height,
            duration = info[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval
            else { return }

        self.bottomConstraint.constant = keyboardHeight
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    func keyboardWillBeHidden(notification: NSNotification) {
        guard
            let info = notification.userInfo,
            duration = info[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval
            else { return }

        self.bottomConstraint.constant = -132
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    private func configNavigationBarByScrollPosition() {

        let offsetY = self.tableView.contentOffset.y
        var headerHeight = TomoConst.UI.TopBarHeight

        if let imageNumber = self.post.images?.count where imageNumber > 0 {
            headerHeight = self.headerHeight
        }

        // begin fade in the navigation bar background at the point which is
        // twice height of topbar above the bottom of the table view header area.
        // and let the fade in complete just when the bottom of navigation bar
        // overlap with the bottom of table header view.
        if offsetY > headerHeight - TomoConst.UI.TopBarHeight * 2 {

            let distance = headerHeight - offsetY - TomoConst.UI.TopBarHeight * 2
            let image = Util.imageWithColor(0x0288D1, alpha: abs(distance) / TomoConst.UI.TopBarHeight)
            self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)

            // if user scroll down so the table header view got shown, just keep the navigation bar transparent
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
}

// MARK: - Actions

extension PostDetailViewController {

    @IBAction func moreButtonTapped(sender: UIBarButtonItem) {

        var optionalList = Dictionary<String,((UIAlertAction!) -> Void)!>()

        /* wechat share is disable tempraray
        if (WechatManager.sharedInstance.isInstalled()) {
            optionalList["微信"] = { _ in
                self.share(WXSceneSession)
            }

            optionalList["朋友圈"] = { _ in
                self.share(WXSceneTimeline)
            }
        } */

        if post.owner.id != me.id {
            optionalList["举报此内容"] = { _ in

                Util.alert(self, title: "举报此内容", message: "您确定要举报此内容吗？") { _ in
                    Router.Report.Post(id: self.post.id).response { _ in
                        Util.showInfo("举报信息已发送")
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
            }
        }

        if post.owner.id == me.id {
            optionalList["删除"] = { _ in
                Util.alert(self, title: "删除帖子", message: "确定删除该帖子吗？") { _ in
                    Router.Post.Delete(id: self.post.id).response { _ in
                        Util.showInfo("帖子已删除")
                        // TODO remove the post in HomeViewController
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
            }
        }

        Util.alertActionSheet(self, optionalDict: optionalList)
    }

    @IBAction func likeButtonTapped(sender: UIButton) {

        sender.userInteractionEnabled = false

        Router.Post.Like(id: post.id).response {

            if $0.result.isFailure {
                sender.userInteractionEnabled = true
                return
            }

            if let like = self.post.like {
                like.contains(me.id) ? self.post.like!.remove(me.id) : self.post.like!.append(me.id)
            } else {
                self.post.like = [me.id]
            }

            self.configInfoLabel()

            sender.userInteractionEnabled = true
        }
    }

    @IBAction func bookmarkButtonTapped(sender: UIButton) {

        sender.userInteractionEnabled = false

        Router.Post.Bookmark(id: post.id).response {

            if $0.result.isFailure {
                sender.userInteractionEnabled = true
                return
            }

            self.post.bookmark = self.post.bookmark ?? []

            if self.post.bookmark!.contains(me.id) {
                self.post.bookmark!.remove(me.id)
            } else {
                self.post.bookmark!.append(me.id)
            }

            self.configInfoLabel()

            sender.userInteractionEnabled = true
        }
    }

    @IBAction func commentButtonTapped(sender: UIButton) {
        // keyboard will show up here, enable the tableview tap recongnizer,
        // so the keyboard will be dismissed later when tap anywhere on screen
        self.blurEffectView.hidden = false
        self.tableViewTapRecognizer.enabled = true
        self.commentTextView.becomeFirstResponder()
    }

    @IBAction func viewTapped(sender: UITapGestureRecognizer) {
        // keyboard is dismissed here, disable the tableview tap recongnizer,
        // so the tap event won't block the table cell tap event.
        self.blurEffectView.hidden = true
        self.tableViewTapRecognizer.enabled = false
        self.commentTextView.resignFirstResponder()
    }

    @IBAction func sendButtonTapped(sender: UIButton) {

        self.sendButton.enabled = false

        // keyboard is dismissed here, disable the tableview tap recongnizer,
        // so the tap event won't block the table cell tap event.
        self.blurEffectView.hidden = true
        self.tableViewTapRecognizer.enabled = false
        self.commentTextView.resignFirstResponder()

        let commentContent = self.commentTextView.text.trimmed()

        Router.Post.Comment(id: self.post.id, content: commentContent).response {

            if $0.result.isFailure { return }

            // clear the previous input
            self.commentTextView.text = nil

            // create comment entity
            let comment = CommentEntity()
            comment.owner = me
            comment.content = commentContent
            comment.createDate = NSDate()

            // use the comment entity to calculate the height of the comment cell that will be insert
            let commentCell = self.tableView.dequeueReusableCellWithIdentifier("CommentCell") as! PostCommentCell
            commentCell.comment = comment
            let commentCellSize = commentCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)

            // create a empty new comment array if the post has no comment
            if self.post.comments == nil {
                self.post.comments = []
            }

            // append the comment on the post
            self.post.comments?.append(comment)

            // insert row height
            self.rowHeights.insert([commentCellSize.height], atIndex: 2)

            // insert the comment cell into table view, and show it
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 2, inSection: 0)], withRowAnimation: .Automatic)
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), atScrollPosition: .Middle, animated: true)
        }
    }
}

// MARK: - UITableView datasource

extension PostDetailViewController: UITableViewDataSource {

    // The row number is one author cell + one content cell + all the comment cells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let comments = self.post.comments {
            return comments.count + 2
        } else {
            return 2
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: UITableViewCell

        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("AuthorInfoCell", forIndexPath: indexPath)
            (cell as! PostDisplayCell).post = self.post
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("ContentCell", forIndexPath: indexPath)
            (cell as! PostDisplayCell).post = self.post
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath)
            (cell as! PostCommentCell).comment = self.post.comments?.reverse()[indexPath.row - 2]
        }

        return cell
    }
}

// MARK: - UITableView delegate

extension PostDetailViewController: UITableViewDelegate {

    // Just return the pre-calculate row heights
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.rowHeights[indexPath.row]
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            // No need to see myself on profile view
            guard me.id != post.owner.id else { return }
            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
            vc.user = post.owner
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            return
        default:
            let commentOwner = post.comments?.reverse()[indexPath.row - 2].owner
            // No need to see myself on profile view
            guard me.id != commentOwner!.id else { return }
            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
            vc.user = commentOwner
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UICollectionView datasource

extension PostDetailViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.post.images?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SingleImageCell", forIndexPath: indexPath) as! SingleImageCollectionViewCell
        cell.imageURL = self.post.images?[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionView delegate

extension PostDetailViewController: UICollectionViewDelegate {

    // when the image collection was tapped, display full size image
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SingleImageCollectionViewCell
        let gallery = MHGalleryController(presentationStyle: MHGalleryViewMode.ImageViewerNavigationBarShown)

        gallery.galleryItems = self.post.images!.map { MHGalleryItem(URL: $0, galleryType: .Image) }
        gallery.presentationIndex = indexPath.item
        gallery.presentingFromImageView = cell.imageView

        gallery.UICustomization.showOverView = false
        gallery.UICustomization.useCustomBackButtonImageOnImageViewer = false
        gallery.UICustomization.showMHShareViewInsteadOfActivityViewController = false

        gallery.finishedCallback = { (currentIndex, image, transition, viewMode) -> Void in
            gallery.dismissViewControllerAnimated(true, dismissImageView: cell.imageView, completion: nil)
        }

        presentMHGalleryController(gallery, animated: true, completion: nil)
    }

    // one image on one cell
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.headerViewSize
    }
}

// MARK: - UIScrollView delegate

extension PostDetailViewController {

    // Display the navigation bar background, the idea is
    // let the navigation bar become opaque when user just scroll over the image area
    func scrollViewDidScroll(scrollView: UIScrollView) {

        // if the post has no image, do nothing
        guard let imageNumber = self.post.images?.count where imageNumber > 0 else { return }

        // in the case that the image collection view was scrolled, update page control
        if scrollView == self.collectionView {

            guard imageNumber > 1 else { return }

            let currentPage = Int(floor((scrollView.contentOffset.x + TomoConst.UI.ScreenWidth / 2.0) / TomoConst.UI.ScreenWidth))

            self.pageControl.currentPage = currentPage

        // in the case that the whole table view was scrolled, animate the navigation bar
        } else {

            self.configNavigationBarByScrollPosition()
        }

    }
}

// MARK: - UITextView Delegate

extension PostDetailViewController: UITextViewDelegate {

    func textViewDidChange(textView: UITextView) {

        if textView.text.trimmed().length > 0 {
            self.sendButton.enabled = true
        } else {
            self.sendButton.enabled = false
        }
    }
}

class PostDisplayCell: UITableViewCell {

    var post: PostEntity! {
        didSet { self.configDisplay() }
    }

    func configDisplay() {

    }
}

final class PostAuthorInfoCell: PostDisplayCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func configDisplay() {

        if let photo = self.post.owner.photo {
            self.avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
        }
        self.nickNameLabel.text = self.post.owner.nickName
        self.dateLabel.text = self.post.createDate.toString()
    }
}

final class PostContentCell: PostDisplayCell {

    @IBOutlet weak var contentLabel: UILabel!

    override func awakeFromNib() {

        super.awakeFromNib()

        // set this to help systemLayoutSizeFittingSize work correctly
        self.contentLabel.preferredMaxLayoutWidth = TomoConst.UI.ScreenWidth - 32
    }

    override func configDisplay() {

        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 30

        let attributeString = NSAttributedString(string: self.post.content, attributes: [
            NSParagraphStyleAttributeName: style
        ])

        self.contentLabel.attributedText = attributeString
    }
}

final class PostCommentCell: UITableViewCell {

    var comment: CommentEntity! {
        didSet { self.configDisplay() }
    }

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {

        super.awakeFromNib()

        // set this to help systemLayoutSizeFittingSize work correctly
        self.commentLabel.preferredMaxLayoutWidth = TomoConst.UI.ScreenWidth - 32 - 50 - 8
    }

    func configDisplay() {

        if let photo = self.comment.owner.photo {
            self.avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
        }
        self.nickNameLabel.text = self.comment.owner.nickName
        self.commentLabel.text = self.comment.content
        self.dateLabel.text = self.comment.createDate.toString()
    }
}