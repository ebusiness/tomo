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
        
        let now = NSDate()
        if let date = post.createDate {
            if !date.isToday() {
                postDateLabel.text = date.toString()
            } else if date.hoursBeforeDate(now) > 0 {
                postDateLabel.text = "\(date.hoursBeforeDate(now))時"
            } else if date.minutesBeforeDate(now) > 0 {
                postDateLabel.text = "\(date.minutesBeforeDate(now))分"
            } else {
                postDateLabel.text = "\(date.seconds())秒"
            }
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
        
        var likeimage = "hearts"
        var bookmarkimage = "star"
        
        if let me = DBController.myUser() {
            
            likeimage = me.liked_posts.containsObject(post) ? "hearts_filled" : "hearts"
            
            bookmarkimage = me.bookmarked_posts.containsObject(post) ? "star_filled" : "star"
            
        }
        if let image = UIImage(named: likeimage) {
            
            let image = Util.coloredImage(image, color: UIColor.redColor())
            likeButton?.setImage(image, forState: .Normal)
            
        }
        
        if let image = UIImage(named: bookmarkimage) {
            
            let image = Util.coloredImage(image, color: UIColor.orangeColor())
            bookmarkButton?.setImage(image, forState: .Normal)
            
        }

    }
    
    @IBAction func likePost() {
        
        ApiController.postLike(post.id!, done: { (error) -> Void in
            self.setupDisplay()
        })
    }

    @IBAction func bookmarkPost(sender: AnyObject) {
        
        ApiController.postBookmark(post.id!, done: { (error) -> Void in
            self.setupDisplay()
        })
    }
}
