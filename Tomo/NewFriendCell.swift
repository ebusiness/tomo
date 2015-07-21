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
    
    var user: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        avatarImageView.layer.cornerRadius = avatarImageView.layer.bounds.width / 2
        avatarImageView.layer.masksToBounds = true
        
        countLabel.layer.cornerRadius = countLabel.layer.bounds.width / 2
        countLabel.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupDisplay() {
        
        if let photo_ref = user?.photo_ref {
            avatarImageView.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
        }
        
        userNameLabel.text = user?.nickName
        
        let count = DBController.unreadCount(user!)
        
        if count > 0 {
            countLabel.hidden = false
            countLabel.text = String(count)
        } else {
            countLabel.hidden = true
        }
        
        if let message = DBController.lastMessage(user!) {
            if message.isMediaMessage() {
                messageLabel.text = MediaMessage.messagePrefix(message.content!)
            } else {
                messageLabel.text = message.content
            }
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            if let date = message.createDate {
                timeLabel.text = dateFormatter.stringFromDate(date)
            } else {
                timeLabel.hidden = true
            }
        } else {
            messageLabel.hidden = true
        }
    }

}
