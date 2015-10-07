//
//  PostCell.swift
//  Tomo
//
//  Created by ebuser on 2015/07/09.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    @IBOutlet weak var tagView: UIView!
    
    @IBOutlet var commentView: UIView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var commentContentLabel: UILabel!
    @IBOutlet weak var commentDateLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var postContentConstriantBottom: NSLayoutConstraint!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var contentWidthConstraint: NSLayoutConstraint!
    
    var post: PostEntity!
    
//    var tableView: UITableView? {
//        get {
//            var table: UIView? = superview
//            while !(table is UITableView) && table != nil {
//                table = table?.superview
//            }
//            
//            return table as? UITableView
//        }
//    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        avatarImageView.layer.borderColor = avatarBorderColor
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        contentWidthConstraint.constant = screenWidth
        
        let majorAvatarTapGesture = UITapGestureRecognizer(target: self, action: "majorAvatarTapped")
        avatarImageView.addGestureRecognizer(majorAvatarTapGesture)
        
        let minorAvatarTapGesture = UITapGestureRecognizer(target: self, action: "minorAvatarTapped")
        commentImageView.addGestureRecognizer(minorAvatarTapGesture)
        
        let commentTapGesture = UITapGestureRecognizer(target: self, action: "commentTapped")
        commentView.addGestureRecognizer(commentTapGesture)
    }
    
    func setupDisplay() {
        
        postContentConstriantBottom.constant = 16
        
        let subviews = self.tagView.subviews
        
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        if let owner = post.owner {
            userNameLabel.text = owner.nickName
            
            if let photo_ref = owner.photo {
                avatarImageView.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
            }
        } else {
            userNameLabel.text = nil
        }
        
        if let group = post.group {
            
            let label = UILabel(frame: CGRectZero)
            
            label.text = group.name
            label.font = UIFont.systemFontOfSize(12)
            label.textAlignment = .Center
            label.textColor = Util.UIColorFromRGB(NavigationBarColorHex, alpha: 1.0)
            
            label.sizeToFit()
            
            label.frame.size.width += 20
            label.frame.size.height += 12
            
            label.layer.borderWidth = 1
            label.layer.cornerRadius = 5
            label.layer.borderColor = Util.UIColorFromRGB(NavigationBarColorHex, alpha: 1.0).CGColor
            
            label.frame = CGRectMake(tagView.bounds.width - label.bounds.width, 0, label.bounds.width, label.bounds.height)
            
            self.tagView.hidden = false
            self.tagView.addSubview(label)
            
            postContentConstriantBottom.constant += 52
        } else {
            self.tagView.hidden = true
        }
        
        if let date = post.createDate {
            postDateLabel.text = date.relativeTimeToString()
        }
        
        if let contentRaw = post.content {
            var content = contentRaw.trimmed()
            postContentLabel.text = content
            postContentLabel.sizeToFit()
        }
        
        if let like = post.like where like.count > 0 {
            likeButton.setTitle("\(like.count)", forState: .Normal)
        } else {
            likeButton.setTitle("", forState: .Normal)
        }
        
        let likeimage = ( self.post.like ?? [] ).contains(me.id) ? "hearts_filled" : "hearts"
        if let image = UIImage(named: likeimage) {
            
            let image = Util.coloredImage(image, color: UIColor.redColor())
            likeButton.setImage(image, forState: .Normal)
            
        }
        
        let bookmarkimage = ( self.post.bookmark ?? [] ).contains(me.id) ? "star_filled" : "star"
        
        if let image = UIImage(named: bookmarkimage) {
            let image = Util.coloredImage(image, color: UIColor.orangeColor())
            bookmarkButton.setImage(image, forState: .Normal)
        }
        
        if let commentImage = UIImage(named: "comments") {
            let image = Util.coloredImage(commentImage, color: Util.UIColorFromRGB(0x1976D2, alpha: 0.5))
            self.commentButton.setImage(image, forState: .Normal)
        }
        
        if let comment = post.comments?.last {
            
            commentView.hidden = false
            postContentConstriantBottom.constant += 72
//            if let parentview = self.tableView {
//                UIView.setAnimationsEnabled(false)
//                parentview.beginUpdates()
//                parentview.endUpdates()
//                UIView.setAnimationsEnabled(true)
//            }
            
            self.commentImageView.sd_setImageWithURL(NSURL(string: comment.owner.photo!), placeholderImage: DefaultAvatarImage)
            self.commentContentLabel.text = comment.content
            self.commentDateLabel.text = comment.createDate.relativeTimeToString()
            
            if let comments = post.comments where comments.count > 0 {
                self.commentButton.setTitle("\(comments.count)", forState: .Normal)
            } else {
                self.commentButton.setTitle("", forState: .Normal)
            }
            
        } else {
            commentView.hidden = true
            
        }
        

    }
    
    @IBAction func likePost(sender: UIButton) {
        sender.userInteractionEnabled = false
        AlamofireController.request(.PATCH, "/posts/\(self.post.id)/like", success: { _ in
            
            if let like = self.post.like {
                like.contains(me.id) ? self.post.like!.remove(me.id) : self.post.like!.append(me.id)
            } else {
                self.post.like = [me.id]
            }
            
            self.likeButton.bounce{
                self.setupDisplay()
                sender.userInteractionEnabled = true
            }
            
        }) { err in
            sender.userInteractionEnabled = true
        }
    }

    @IBAction func bookmarkPost(sender: UIButton) {
        sender.userInteractionEnabled = false
        AlamofireController.request(.PATCH, "/posts/\(self.post.id)/bookmark", success: { _ in
            
            self.post.bookmark = self.post.bookmark ?? []
            
            if self.post.bookmark!.contains(me.id) {
                self.post.bookmark!.remove(me.id)
            } else {
                self.post.bookmark!.append(me.id)
            }
            self.setupDisplay()
            self.bookmarkButton.tada {
                sender.userInteractionEnabled = true
            }
        }) { err in
            sender.userInteractionEnabled = true
        }

    }
}

// MARK: - Gestures
extension PostCell {
    func majorAvatarTapped() {
        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = self.post.owner
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func minorAvatarTapped() {
        if let member = self.post.comments?.last?.owner {
            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
            vc.user = member
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func commentTapped() {
        let vc = Util.createViewControllerWithIdentifier("PostView", storyboardName: "Home") as! PostViewController
        vc.isCommentInitial = true
        vc.post = self.post
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
