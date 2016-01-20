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

    weak var delegate: UIViewController?

    var post: PostEntity! {
        didSet { self.configDisplay() }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // major avatar tap
        let avatarTap = UITapGestureRecognizer(target: self, action: "avatarTapped")
        avatarImageView.addGestureRecognizer(avatarTap)

        // minor avatar tap
        let commentAvatarTap = UITapGestureRecognizer(target: self, action: "commentAvatarTapped")
        commentAvatarImageView.addGestureRecognizer(commentAvatarTap)

        // comment tap
        let commentTap = UITapGestureRecognizer(target: self, action: "commentTapped")
        commentArea.addGestureRecognizer(commentTap)

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

    func avatarTapped() {

        guard let owner = post?.owner else { return }

        let profileViewController = delegate?.navigationController?.childViewControllers.find { ($0 as? ProfileViewController)?.user.id == owner.id } as? ProfileViewController

        if let profileViewController = profileViewController {
            delegate?.navigationController?.popToViewController(profileViewController, animated: true)
        } else {
            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
            vc.user = owner
            delegate?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func commentAvatarTapped() {
        guard let owner = post?.comments?.last?.owner else { return }

        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = owner
        if owner.id == post?.owner.id {
            let profileViewController = delegate?.navigationController?.childViewControllers.find { $0 is ProfileViewController } as? ProfileViewController

            if let profileViewController = profileViewController {
                delegate?.navigationController?.popToViewController(profileViewController, animated: true)
                return
            }
        }
        delegate?.navigationController?.pushViewController(vc, animated: true)
    }

    func commentTapped() {
        if nil == post?.comments?.last { return }

        let vc = Util.createViewControllerWithIdentifier("PostView", storyboardName: "Home") as! PostViewController
        vc.post = post!
        vc.isCommentInitial = true
        delegate?.navigationController?.pushViewController(vc, animated: true)
    }

    func configDisplay() {

        avatarImageView.sd_setImageWithURL(NSURL(string: post.owner.photo ?? ""), placeholderImage: TomoConst.Image.DefaultAvatar)
        nickNameLabel.text = post.owner.nickName
        postDateLabel.text = post.createDate.relativeTimeToString()
        contentLabel.text = post.content

        var info = [String]()

        if let bookmarks = post.bookmark where bookmarks.contains(me.id) {
            bookmarkButton.setImage(TomoConst.Image.FilledStar, forState: .Normal)
            info.push("\(bookmarks.count)人收藏")
        } else {
            bookmarkButton.setImage(TomoConst.Image.EmptyStar, forState: .Normal)
        }

        if let likes = post.like where likes.contains(me.id) {
            likeButton.setImage(TomoConst.Image.FilledHeart, forState: .Normal)
            info.push("\(likes.count)人点赞")
        } else {
            likeButton.setImage(TomoConst.Image.EmptyHeart, forState: .Normal)
        }

        if let lastComment = post.comments?.last {
            commentAreaHeight.constant = 64.0
            commentAvatarImageView.sd_setImageWithURL(NSURL(string: lastComment.owner.photo ?? ""), placeholderImage: TomoConst.Image.DefaultAvatar)
            commentContentLabel.text = lastComment.content
            commentDateLabel.text = lastComment.createDate.relativeTimeToString()
            info.push("\(post.comments!.count)个评论")
        } else {
            commentAreaHeight.constant = CGFloat.almostZero
            commentAvatarImageView.image = nil
            commentContentLabel.text = nil
            commentDateLabel.text = nil
        }
        
        if info.count > 0 {
            infoLabel.text = info.joinWithSeparator("，")
        } else {
            infoLabel.text = nil
        }

    }
}
