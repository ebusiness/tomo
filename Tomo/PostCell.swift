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
        
        if let likeImage = likeButton.imageView?.image {
//            let color = Util.UIColorFromRGB(0x2196F3, alpha: 1)
            let image = Util.coloredImage(likeImage, color: UIColor.redColor())
            likeButton?.setImage(image, forState: UIControlState.Normal)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        
        postContentLabel.text = post.content

    }

}
