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

    @IBOutlet var commentView: UIView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var commentContentLabel: UILabel!
    @IBOutlet weak var commentDateLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet var commentConstriantTop: NSLayoutConstraint!
    @IBOutlet var commentConstriantBottom: NSLayoutConstraint!
    @IBOutlet var commentConstraintTrail: NSLayoutConstraint!
    @IBOutlet var commentConstriantLead: NSLayoutConstraint!
    @IBOutlet var commentConstriantHeight: NSLayoutConstraint!
    
    @IBOutlet weak var bottomLine: UIView!
    
    var constraintsWithComment: [NSLayoutConstraint]!
    var constraintsWithOutComment: [NSLayoutConstraint]!
    
    var post: PostEntity!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        
        commentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        constraintsWithOutComment = NSLayoutConstraint.constraintsWithVisualFormat("V:[v1]-(8)-[v2]", options: nil, metrics: nil, views: ["v1": self.postContentLabel, "v2": self.bottomLine]) as! [NSLayoutConstraint]
        
        constraintsWithComment = [commentConstriantTop,commentConstriantBottom,commentConstraintTrail,commentConstriantLead,commentConstriantHeight]
        
    }
    
    func setupDisplay() {
        
        if let owner = post.owner {
            userNameLabel.text = owner.nickName
            
            if let photo_ref = owner.photo {
                avatarImageView.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
            }
        } else {
            userNameLabel.text = nil
        }
        
        if let date = post.createDate {
            postDateLabel.text = date.relativeTimeToString()
        }
        
        if let contentRaw = post.content {
            var content = contentRaw.trimmed()
            postContentLabel.text = content
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
            
            self.commentImageView.sd_setImageWithURL(NSURL(string: comment.owner.photo!), placeholderImage: DefaultAvatarImage)
            self.commentContentLabel.text = comment.content
            self.commentDateLabel.text = comment.createDate.relativeTimeToString()
            
            if let comments = post.comments where comments.count > 0 {
                self.commentButton.setTitle("\(comments.count)", forState: .Normal)
            } else {
                self.commentButton.setTitle("", forState: .Normal)
            }
            
            self.addSubview(commentView)
            NSLayoutConstraint.deactivateConstraints(self.constraintsWithOutComment)
            NSLayoutConstraint.activateConstraints(self.constraintsWithComment)
            
        } else {
            
            commentView.removeFromSuperview()
            NSLayoutConstraint.activateConstraints(self.constraintsWithOutComment)
            NSLayoutConstraint.deactivateConstraints(self.constraintsWithComment)
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
            
            me.bookmark = me.bookmark ?? []
            self.post.bookmark = self.post.bookmark ?? []
            
            if me.bookmark!.contains(self.post.id) {
                me.bookmark!.remove(self.post.id)
                self.post.bookmark!.remove(me.id)
            } else {
                me.bookmark!.append(self.post.id)
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
