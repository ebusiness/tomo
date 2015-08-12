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
    
    var post: PostEntity!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        cardView.layer.cornerRadius = 5
        cardView.layer.masksToBounds = true
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = Util.UIColorFromRGB(0xDDDDDD, alpha: 1).CGColor
        
        avatarImageView.layer.cornerRadius = 25.0
        avatarImageView.layer.masksToBounds = true
        
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
        
        if post.content?.length > 150 {
            
            let index = advance(post.content!.startIndex, 150)
            let display = post.content?.substringToIndex(index)
            
            postContentLabel.text = String(format: "%@...", display!)
            
        } else {
            postContentLabel.text = post.content
        }
        
        if let like = post.like {
            likeButton.setTitle("\(like.count)", forState: .Normal)
        }
        
//        bookmarkButton.setTitle("\(post.bookmark?.count)", forState: .Normal)
        
        
        let likeimage = ( self.post.like ?? [] ).contains(me.id) ? "hearts_filled" : "hearts"
        if let image = UIImage(named: likeimage) {
            
            let image = Util.coloredImage(image, color: UIColor.redColor())
            likeButton?.setImage(image, forState: .Normal)
            
        }
        
        let bookmarkimage = ( me.bookmark ?? [] ).contains(self.post.id) ? "star_filled" : "star"
        
        if let image = UIImage(named: bookmarkimage) {
            
            let image = Util.coloredImage(image, color: UIColor.orangeColor())
            bookmarkButton?.setImage(image, forState: .Normal)
            
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
                self.setupDisplay()
                self.likeButton.pulse(nil)
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
        }

    }
}
