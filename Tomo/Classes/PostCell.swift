//
//  PostCell.swift
//  Tomo
//
//  Created by ebuser on 2015/07/09.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    @IBOutlet weak var commentHeight: NSLayoutConstraint!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var commentContentLabel: UILabel!
    @IBOutlet weak var commentDateLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    var post: PostEntity!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        cardView.layer.cornerRadius = 5
        cardView.layer.masksToBounds = true
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = Util.UIColorFromRGB(0xDDDDDD, alpha: 1).CGColor
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.layer.masksToBounds = true
        
        commentImageView.layer.cornerRadius = commentImageView.bounds.width / 2
        commentImageView.layer.masksToBounds = true
        
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
        
        let bookmarkimage = ( me.bookmark ?? [] ).contains(self.post.id) ? "star_filled" : "star"
        
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
            
            self.commentHeight.constant = 62
        } else {
            self.commentHeight.constant = 0
        }
        
        if let comments = post.comments where comments.count > 0 {
            self.commentButton.setTitle("\(comments.count)", forState: .Normal)
        } else {
            self.commentButton.setTitle("", forState: .Normal)
        }

    }
    
    @IBAction func likePost() {
        Manager.sharedInstance.request(.PATCH, kAPIBaseURLString + "/posts/\(self.post.id)/like")
            .response { (_, _, _, _) -> Void in
                
                if let like = self.post.like {
                    like.contains(me.id) ? self.post.like!.remove(me.id) : self.post.like!.append(me.id)
                } else {
                    self.post.like = [me.id]
                }
                self.likeButton.bounce({ () -> Void in
                    self.setupDisplay()
                })
        }
    }

    @IBAction func bookmarkPost(sender: AnyObject) {
        
        Manager.sharedInstance.request(.PATCH, kAPIBaseURLString + "/posts/\(self.post.id)/bookmark")
            .response { (_, _, _, _) -> Void in
                
                if let bookmark = me.bookmark {
                    bookmark.contains(self.post.id) ? me.bookmark!.remove(self.post.id) : me.bookmark!.append(self.post.id)
                } else {
                    me.bookmark = [self.post.id]
                }
                self.setupDisplay()
                self.bookmarkButton.tada(nil)
        }

    }
}
