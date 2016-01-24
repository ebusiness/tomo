//
//  TextPostTableViewCell.swift
//  Tomo
//
//  Created by ebuser on 2016/01/20.
//  Copyright © 2016年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class TextPostTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var nickNameLabel: UILabel!

    @IBOutlet weak var postDateLabel: UILabel!

    @IBOutlet weak var contentLabel: UILabel!

    @IBOutlet weak var infoLabel: UILabel!

    @IBOutlet weak var likeButton: UIButton!

    @IBOutlet weak var bookmarkButton: UIButton!

    @IBOutlet weak var commentArea: UIView!

    @IBOutlet weak var commentAreaHeight: NSLayoutConstraint!

    @IBOutlet weak var commentAvatarImageView: UIImageView!

    @IBOutlet weak var commentContentLabel: UILabel!

    @IBOutlet weak var commentDateLabel: UILabel!

    weak var delegate: UINavigationController?

    var post: PostEntity! {
        didSet { self.configDisplay() }
    }

    override func awakeFromNib() {

        super.awakeFromNib()

        // post author avatar tap
        let avatarTap = UITapGestureRecognizer(target: self, action: "avatarTapped")
        self.avatarImageView.addGestureRecognizer(avatarTap)

        // comment author avatar tap
        let commentAvatarTap = UITapGestureRecognizer(target: self, action: "commentAvatarTapped")
        self.commentAvatarImageView.addGestureRecognizer(commentAvatarTap)

        // comment tap
        let commentTap = UITapGestureRecognizer(target: self, action: "commentTapped")
        self.commentArea.addGestureRecognizer(commentTap)

        // set this to help systemLayoutSizeFittingSize work correctly
        self.contentLabel.preferredMaxLayoutWidth = TomoConst.UI.ScreenWidth - 32

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

            self.configDisplay()

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

            self.configDisplay()

            sender.userInteractionEnabled = true
        }
    }

    // When post author avatar was tappaed, move to post author's profile
    func avatarTapped() {

        guard let owner = post?.owner else { return }

        // TODO: this is wired, but for prevent infinite loop, should fix
        let profileViewController = self.delegate?.childViewControllers.find { ($0 as? ProfileViewController)?.user.id == owner.id } as? ProfileViewController

        if let profileViewController = profileViewController {
            self.delegate?.popToViewController(profileViewController, animated: true)
        } else {
            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
            vc.user = owner
            self.delegate?.pushViewController(vc, animated: true)
        }
    }

    // When comment author avatar was tappaed, move to comment author's profile
    func commentAvatarTapped() {

        guard let owner = post?.comments?.last?.owner else { return }

        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = owner
        if owner.id == post?.owner.id {
            let profileViewController = self.delegate?.childViewControllers.find { $0 is ProfileViewController } as? ProfileViewController

            if let profileViewController = profileViewController {
                self.delegate?.popToViewController(profileViewController, animated: true)
                return
            }
        }
        delegate?.pushViewController(vc, animated: true)
    }

    // When comment was tappaed, move to comment area of the post detail
    func commentTapped() {

        if nil == post?.comments?.last { return }

        let vc = Util.createViewControllerWithIdentifier("PostDetailViewController", storyboardName: "Home") as! PostDetailViewController
        vc.post = post!

        // TODO: this should be dynamic via user input,
        vc.initialCommentIndex = 2
        
        self.delegate?.pushViewController(vc, animated: true)
    }

    func configDisplay() {

        self.avatarImageView.sd_setImageWithURL(NSURL(string: post.owner.photo ?? ""), placeholderImage: TomoConst.Image.DefaultAvatar)
        self.nickNameLabel.text = post.owner.nickName
        self.postDateLabel.text = post.createDate.relativeTimeToString()
        self.contentLabel.text = post.content

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

        if let lastComment = post.comments?.last {
            self.commentAreaHeight.constant = 64.0
            self.commentAvatarImageView.sd_setImageWithURL(NSURL(string: lastComment.owner.photo ?? ""), placeholderImage: TomoConst.Image.DefaultAvatar)
            self.commentContentLabel.text = lastComment.content
            self.commentDateLabel.text = lastComment.createDate.relativeTimeToString()
            info.push("\(post.comments!.count)评论")
        } else {
            self.commentAreaHeight.constant = CGFloat.almostZero
            self.commentAvatarImageView.image = nil
            self.commentContentLabel.text = nil
            self.commentDateLabel.text = nil
        }
        
        if info.count > 0 {
            self.infoLabel.text = info.joinWithSeparator(" ")
        } else {
            self.infoLabel.text = nil
        }
    }
    
}
