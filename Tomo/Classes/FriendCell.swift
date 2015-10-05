//
//  FriendCell.swift
//  Tomo
//
//  Created by ebuser on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!//left right constraints == (sqrt(2)-1) * avatarImageView.frame.size.width / 2 / sqrt(2) - countLabel.frame.size.width / 2
    @IBOutlet weak var timeLabel: UILabel!
    
    var user: UserEntity!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        countLabel.layer.borderWidth = 2
        countLabel.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    func setupDisplay() {
        
        if let photo = user.photo {
            avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
        }
        
        userNameLabel.text = user.nickName
        
        let count = me.newMessages.reduce(0, combine: { (count, message) -> Int in
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
        
        if let message = user.lastMessage {
            if let media = MediaMessage.mediaMessage(message.content) {
                messageLabel.text = self.getMediaString(media)
            } else {
                messageLabel.text = message.content
            }
            timeLabel.text = message.createDate.relativeTimeToString()
        } else {
            messageLabel.hidden = true
            timeLabel.hidden = true
        }
        
    }
    
    private func getMediaString(media: MediaMessage)-> String {
        switch media {
        case .Image:
            return "发给您一张图片"
        case .Voice:
            return "发给您一段语音"
        case .Video:
            return "发给您一段视频"
        }
    }

}
