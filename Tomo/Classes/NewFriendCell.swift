//
//  FriendCell.swift
//  Tomo
//
//  Created by ebuser on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NewFriendCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var user: UserEntity?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        avatarImageView.layer.cornerRadius = avatarImageView.layer.bounds.width / 2
        avatarImageView.layer.masksToBounds = true
        
        countLabel.layer.cornerRadius = countLabel.layer.bounds.width / 2
        countLabel.layer.masksToBounds = true
    }
    
    func setupDisplay() {
        
        if let photo = user?.photo {
            avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
        }
        
        userNameLabel.text = user?.nickName
        
        let count = me.newMessages!.reduce(0, combine: { (count, message) -> Int in
            if message.from.id == user!.id {
                return count + 1
            } else {
                return count
            }
        })
        
        if count > 0 {
            countLabel.hidden = false
            countLabel.text = String(count)
        } else {
            countLabel.hidden = true
        }
        
        if let message = user?.lastMessage {
            messageLabel.text = message.content
            timeLabel.text = message.createDate.relativeTimeToString()
        } else {
            messageLabel.hidden = true
            timeLabel.hidden = true
        }
        
    }

}
