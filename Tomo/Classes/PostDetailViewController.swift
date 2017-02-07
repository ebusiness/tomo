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
            self.collectionView.scrollToItem(at: IndexPath(item: initialImageIndex, section: 0), at: .centeredHorizontally, animated: false)
        }

        if let initialCommentIndex = self.initialCommentIndex {
            self.tableView.scrollToRow(at: IndexPath(item: initialCommentIndex, section: 0), at: .top, animated: false)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        // restore the normal navigation bar before disappear
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        self.configNavigationBarByScrollPosition()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Internal methods

extension PostDetailViewController {

    fileprivate func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(PostDetailViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostDetailViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    fileprivate func configDisplay() {

        // don't interrupt the scroll to top function of main scroll view
        self.collectionView.scrollsToTop = false
        self.commentTextView.scrollsToTop = false

        if let imageNumber = self.post.images?.count, imageNumber > 0 {

            if imageNumber > 1 {
                self.pageControl.numberOfPages = imageNumber
                self.pageControl.currentPage = 0
            } else {
                self.pageControl.isHidden = true
            }

            // set the header view's size according the screen size
            self.tableView.tableHeaderView?.frame = CGRect(origin: CGPoint.zero, size: self.headerViewSize)

        } else {

            // set the header view's size as tall as the top bar
            self.tableView.tableHeaderView?.frame = CGRect(origin: CGPoint.zero, size: self.emptyHeaderViewSize)
        }

    }

    fileprivate func calculateRowHeight() {

        let authorInfoCell = self.tableView.dequeueReusableCell(withIdentifier: "AuthorInfoCell") as? PostDisplayCell
        let contentCell = self.tableView.dequeueReusableCell(withIdentifier: "ContentCell") as? PostDisplayCell

        authorInfoCell?.post = self.post
        contentCell?.post = self.post

        // calculate the author info cell
        let authorInfoCellSize = authorInfoCell!.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)

        // calculate the content cell
        let contentCellSize = contentCell!.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)

        self.rowHeights.append(authorInfoCellSize.height)
        self.rowHeights.append(contentCellSize.height)

        // calculate all the comment cells
        if let comments = self.post.comments {

            let commentCell = self.tableView.dequeueReusableCell(withIdentifier: "CommentCell") as? PostCommentCell

            self.rowHeights.append(contentsOf: comments.reversed().map {
                commentCell?.comment = $0
                let commentCellSize = commentCell?.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                return commentCellSize!.height
            })
        }
    }

    fileprivate func configInfoLabel() {

        var info = [String]()

        if let likes = post.like, likes.contains(me.id) {
            self.likeButton.setImage(TomoConst.Image.FilledHeart, for: .normal)
            info.append("\(likes.count)赞")
        } else {
            self.likeButton.setImage(TomoConst.Image.EmptyHeart, for: .normal)
        }

        if let bookmarks = post.bookmark, bookmarks.contains(me.id) {
            self.bookmarkButton.setImage(TomoConst.Image.FilledStar, for: .normal)
            info.append("\(bookmarks.count)收藏")
        } else {
            self.bookmarkButton.setImage(TomoConst.Image.EmptyStar, for: .normal)
        }

        if let comments = post.comments, !comments.isEmpty {
            info.append("\(comments.count)评论")
        }

        if !info.isEmpty {
            self.infoLabel.text = info.joined(separator: " ")
        } else {
            self.infoLabel.text = nil
        }
    }

    func keyboardWillShow(_ notification: NSNotification) {
        guard
            let info = notification.userInfo,
            let keyboardHeight = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height,
            let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval
            else { return }

        self.bottomConstraint.constant = keyboardHeight
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    func keyboardWillBeHidden(_ notification: NSNotification) {
        guard
            let info = notification.userInfo,
            let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval
            else { return }

        self.bottomConstraint.constant = -132
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    fileprivate func configNavigationBarByScrollPosition() {

        let offsetY = self.tableView.contentOffset.y
        var headerHeight = TomoConst.UI.TopBarHeight

        if let imageNumber = self.post.images?.count, imageNumber > 0 {
            headerHeight = self.headerHeight
        }

        // begin fade in the navigation bar background at the point which is
        // twice height of topbar above the bottom of the table view header area.
        // and let the fade in complete just when the bottom of navigation bar
        // overlap with the bottom of table header view.
        if offsetY > headerHeight - TomoConst.UI.TopBarHeight * 2 {

            let distance = headerHeight - offsetY - TomoConst.UI.TopBarHeight * 2
            let image = Util.imageWithColor(rgbValue: 0x0288D1, alpha: abs(distance) / TomoConst.UI.TopBarHeight)
            self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)

            // if user scroll down so the table header view got shown, just keep the navigation bar transparent
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
}

// MARK: - Actions

extension PostDetailViewController {

    @IBAction func moreButtonTapped(_ sender: UIBarButtonItem) {

        var optionalList = Dictionary<String,((UIAlertAction?) -> Void)!>()

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

                Util.alert(parentvc: self, title: "举报此内容", message: "您确定要举报此内容吗？") { _ in
                    Router.Report.Post(id: self.post.id).response { _ in
                        Util.showInfo(title: "举报信息已发送")
                        self.navigationController?.pop(animated: true)
                    }
                }
            }
        }

        if post.owner.id == me.id {
            optionalList["删除"] = { _ in
                Util.alert(parentvc: self, title: "删除帖子", message: "确定删除该帖子吗？") { _ in
                    Router.Post.Delete(id: self.post.id).response { _ in
                        Util.showInfo(title: "帖子已删除")
                        // TODO remove the post in HomeViewController
                        self.navigationController?.pop(animated: true)
                    }
                }
            }
        }

        Util.alertActionSheet(parentvc: self, optionalDict: optionalList)
    }

    @IBAction func likeButtonTapped(_ sender: UIButton) {

        sender.isUserInteractionEnabled = false

        Router.Post.Like(id: post.id).response {

            if $0.result.isFailure {
                sender.isUserInteractionEnabled = true
                return
            }

            if let like = self.post.like {
                like.contains(me.id) ? self.post.like!.remove(me.id) : self.post.like!.append(me.id)
            } else {
                self.post.like = [me.id]
            }

            self.configInfoLabel()

            sender.isUserInteractionEnabled = true
        }
    }

    @IBAction func bookmarkButtonTapped(_ sender: UIButton) {

        sender.isUserInteractionEnabled = false

        Router.Post.Bookmark(id: post.id).response {

            if $0.result.isFailure {
                sender.isUserInteractionEnabled = true
                return
            }

            self.post.bookmark = self.post.bookmark ?? []

            if self.post.bookmark!.contains(me.id) {
                self.post.bookmark!.remove(me.id)
            } else {
                self.post.bookmark!.append(me.id)
            }

            self.configInfoLabel()

            sender.isUserInteractionEnabled = true
        }
    }

    @IBAction func commentButtonTapped(_ sender: UIButton) {
        // keyboard will show up here, enable the tableview tap recongnizer,
        // so the keyboard will be dismissed later when tap anywhere on screen
        self.blurEffectView.isHidden = false
        self.tableViewTapRecognizer.isEnabled = true
        self.commentTextView.becomeFirstResponder()
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        // keyboard is dismissed here, disable the tableview tap recongnizer,
        // so the tap event won't block the table cell tap event.
        self.blurEffectView.isHidden = true
        self.tableViewTapRecognizer.isEnabled = false
        self.commentTextView.resignFirstResponder()
    }

    @IBAction func sendButtonTapped(_ sender: UIButton) {

        self.sendButton.isEnabled = false

        // keyboard is dismissed here, disable the tableview tap recongnizer,
        // so the tap event won't block the table cell tap event.
        self.blurEffectView.isHidden = true
        self.tableViewTapRecognizer.isEnabled = false
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
            comment.createDate = Date()

            // use the comment entity to calculate the height of the comment cell that will be insert
            let commentCell = self.tableView.dequeueReusableCell(withIdentifier: "CommentCell") as? PostCommentCell
            commentCell?.comment = comment
            let commentCellSize = commentCell!.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)

            // create a empty new comment array if the post has no comment
            if self.post.comments == nil {
                self.post.comments = []
            }

            // append the comment on the post
            self.post.comments?.append(comment)

            // insert row height
            self.rowHeights.insert(commentCellSize.height, at: 2)

            // insert the comment cell into table view, and show it
            self.tableView.insertRows(at: [IndexPath(item: 2, section: 0)], with: .automatic)
            self.tableView.scrollToRow(at: IndexPath(item: 2, section: 0), at: .middle, animated: true)
        }
    }
}

// MARK: - UITableView datasource

extension PostDetailViewController: UITableViewDataSource {

    // The row number is one author cell + one content cell + all the comment cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let comments = self.post.comments {
            return comments.count + 2
        } else {
            return 2
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell

        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "AuthorInfoCell", for: indexPath)
            (cell as? PostDisplayCell)!.post = self.post
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath)
            (cell as? PostDisplayCell)!.post = self.post
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
            (cell as? PostCommentCell)!.comment = self.post.comments?.reversed()[indexPath.row - 2]
        }

        return cell
    }
}

// MARK: - UITableView delegate

extension PostDetailViewController: UITableViewDelegate {

    // Just return the pre-calculate row heights
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeights[indexPath.row]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            // No need to see myself on profile view
            guard me.id != post.owner.id else { return }
            let vc = Util.createViewControllerWithIdentifier(id: "ProfileView", storyboardName: "Profile") as? ProfileViewController
            vc?.user = post.owner
            self.navigationController?.pushViewController(vc!, animated: true)
        case 1:
            return
        default:
            let commentOwner = post.comments?.reversed()[indexPath.row - 2].owner
            // No need to see myself on profile view
            guard me.id != commentOwner!.id else { return }
            let vc = Util.createViewControllerWithIdentifier(id: "ProfileView", storyboardName: "Profile") as? ProfileViewController
            vc?.user = commentOwner
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
}

// MARK: - UICollectionView datasource

extension PostDetailViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.post.images?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleImageCell", for: indexPath) as? SingleImageCollectionViewCell
        cell?.imageURL = self.post.images?[indexPath.row]
        return cell!
    }
}

// MARK: - UICollectionView delegate

extension PostDetailViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // when the image collection was tapped, display full size image
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

//        let cell = collectionView.cellForItem(at: indexPath) as! SingleImageCollectionViewCell
//        let gallery = MHGalleryController(presentationStyle: MHGalleryViewMode.imageViewerNavigationBarShown)
//
//        gallery?.galleryItems = self.post.images!.map { MHGalleryItem(url: $0, galleryType: .image) }
//        gallery?.presentationIndex = indexPath.item
//        gallery?.presentingFromImageView = cell.imageView
//
//        gallery?.uiCustomization.showOverView = false
//        gallery?.uiCustomization.useCustomBackButtonImageOnImageViewer = false
//        gallery?.uiCustomization.showMHShareViewInsteadOfActivityViewController = false
//
//        gallery?.finishedCallback = { (currentIndex, image, transition, viewMode) -> Void in
//            gallery?.dismiss(animated: true, dismiss: cell.imageView, completion: nil)
//        }
//
//        present(gallery, animated: true, completion: nil)
    }

    // one image on one cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.headerViewSize
    }
}

// MARK: - UIScrollView delegate

extension PostDetailViewController {

    // Display the navigation bar background, the idea is
    // let the navigation bar become opaque when user just scroll over the image area
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // if the post has no image, do nothing
        guard let imageNumber = self.post.images?.count, imageNumber > 0 else { return }

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

    func textViewDidChange(_ textView: UITextView) {

        if !textView.text.trimmed().isEmpty {
            self.sendButton.isEnabled = true
        } else {
            self.sendButton.isEnabled = false
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
            self.avatarImageView.sd_setImage(with: URL(string: photo), placeholderImage: defaultAvatarImage)
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
            self.avatarImageView.sd_setImage(with: URL(string: photo), placeholderImage: defaultAvatarImage)
        }
        self.nickNameLabel.text = self.comment.owner.nickName
        self.commentLabel.text = self.comment.content
        self.dateLabel.text = self.comment.createDate.toString()
    }
}
