//
//  PostCell.swift
//  Tomo
//
//  Created by ebuser on 2015/07/09.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = 25.0
        avatarImageView.layer.masksToBounds = true
        
    }
    
    func setupDisplay() {
        
        if let owner = post.owner {
            userNameLabel.text = owner.nickName
            
            if let photo_ref = owner.photo_ref {
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
        
        if post.content?.length > 200 {
            
            let index = advance(post.content!.startIndex, 200)
            let display = post.content?.substringToIndex(index)
            
            postContentLabel.text = String(format: "%@...", display!)
            
        } else {
            postContentLabel.text = post.content
        }
        
        
        var likeImage: UIImage?
        
        if post.liked.count > 0 {
            likeImage = UIImage(named: "hearts_filled")
            likeButton.setTitle(String(post.liked.count), forState: UIControlState.Normal)
        } else {
            likeImage = UIImage(named: "hearts")
            likeButton.setTitle("", forState: UIControlState.Normal)
        }
        
        if let likeImage = likeImage {
            
            let image = Util.coloredImage(likeImage, color: UIColor.redColor())
            
            likeButton?.setImage(image, forState: UIControlState.Normal)
        }
        
        likeButton.sizeToFit()

    }
    
    @IBAction func likePost() {
        
        ApiController.postLike(post.id!, done: { (error) -> Void in
            self.setupDisplay()
        })
    }

}
