//
//  TextPostTableViewCell.swift
//  Tomo
//
//  Created by ebuser on 2016/01/20.
//  Copyright © 2016 e-business. All rights reserved.
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
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(TextPostTableViewCell.avatarTapped))
        self.avatarImageView.addGestureRecognizer(avatarTap)

        // comment author avatar tap
        let commentAvatarTap = UITapGestureRecognizer(target: self, action: #selector(TextPostTableViewCell.commentAvatarTapped))
        self.commentAvatarImageView.addGestureRecognizer(commentAvatarTap)

        // comment tap
        let commentTap = UITapGestureRecognizer(target: self, action: #selector(TextPostTableViewCell.commentTapped))
        self.commentArea.addGestureRecognizer(commentTap)

        // set this to help systemLayoutSizeFittingSize work correctly
        self.contentLabel.preferredMaxLayoutWidth = TomoConst.UI.ScreenWidth - 32

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

            self.configDisplay()

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

            self.configDisplay()

            sender.isUserInteractionEnabled = true
        }
    }

    // When post author avatar was tappaed, move to post author's profile
    func avatarTapped() {

        // No need to see myself on profile view
        guard me.id != post.owner.id else { return }
        guard let owner = post.owner else { return }

        // TODO: this is wired, but for prevent infinite loop, should fix
        let profileViewController = self.delegate?.childViewControllers.first(where: { ($0 as? ProfileViewController)?.user.id == owner.id}) as? ProfileViewController

        if let profileViewController = profileViewController {
            self.delegate?.pop(to: profileViewController, animated: true)
        } else {
            let vc = Util.createViewControllerWithIdentifier(id: "ProfileView", storyboardName: "Profile") as? ProfileViewController
            vc?.user = owner
            self.delegate?.pushViewController(vc!, animated: true)
        }
    }

    // When comment author avatar was tappaed, move to comment author's profile
    func commentAvatarTapped() {

        // No need to see myself on profile view
        guard me.id != post.comments?.last?.owner.id else { return }
        guard let owner = post.comments?.last?.owner else { return }

        let vc = Util.createViewControllerWithIdentifier(id: "ProfileView", storyboardName: "Profile") as? ProfileViewController
        vc?.user = owner
        if owner.id == post.owner.id {
            let profileViewController = self.delegate?.childViewControllers.first(where: { $0 is ProfileViewController }) as? ProfileViewController

            if let profileViewController = profileViewController {
                self.delegate?.pop(to: profileViewController, animated: true)
                return
            }
        }
        delegate?.pushViewController(vc!, animated: true)
    }

    // When comment was tappaed, move to comment area of the post detail
    func commentTapped() {

        if nil == post.comments?.last { return }

        let vc = Util.createViewControllerWithIdentifier(id: "PostDetailViewController", storyboardName: "Home") as? PostDetailViewController
        vc?.post = post!

        // TODO: this should be dynamic via user input,
        vc?.initialCommentIndex = 2

        self.delegate?.pushViewController(vc!, animated: true)
    }

    func configDisplay() {

        self.avatarImageView.sd_setImage(with: URL(string: post.owner.photo ?? ""), placeholderImage: TomoConst.Image.DefaultAvatar)
        self.nickNameLabel.text = post.owner.nickName
        self.postDateLabel.text = post.createDate.relativeTimeToString()
        self.contentLabel.text = post.content

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

        if let lastComment = post.comments?.last {
            self.commentAreaHeight.constant = 64.0
            self.commentAvatarImageView.sd_setImage(with: URL(string: lastComment.owner.photo ?? ""), placeholderImage: TomoConst.Image.DefaultAvatar)
            self.commentContentLabel.text = lastComment.content
            self.commentDateLabel.text = lastComment.createDate.relativeTimeToString()
            info.append("\(post.comments!.count)评论")
        } else {
            self.commentAreaHeight.constant = CGFloat.almostZero
            self.commentAvatarImageView.image = nil
            self.commentContentLabel.text = nil
            self.commentDateLabel.text = nil
        }

        if !info.isEmpty {
            self.infoLabel.text = info.joined(separator: " ")
        } else {
            self.infoLabel.text = nil
        }
    }

}
