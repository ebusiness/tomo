//
//  MyGroupCell.swift
//  Tomo
//
//  Created by ebuser on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class MyGroupCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var group: GroupEntity!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        countLabel.layer.borderWidth = 2
        countLabel.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    func setupDisplay() {
        
        if let cover = group.cover {
            avatarImageView.sd_setImageWithURL(NSURL(string: cover), placeholderImage: DefaultAvatarImage)
        }
        
        userNameLabel.text = group.name
        
        let count = me.newMessages.reduce(0, combine: { (count, message) -> Int in
            if message.group?.id == group.id {
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
        
        if let message = group.lastMessage {
            messageLabel.text = self.getMediaString(message)
            timeLabel.text = message.createDate.relativeTimeToString()
        } else {
            messageLabel.hidden = true
            timeLabel.hidden = true
        }
        
    }
    
    private func getMediaString(message: MessageEntity)-> String {
        let msg = group.lastMessage?.from.id == me.id ? "您发送" : "您接收到"
        switch message.type {
        case .photo:
            return "\(msg)一张图片"
        case .voice:
            return "\(msg)一段语音"
        case .video:
            return "\(msg)一段视频"
        case .text:
            return message.content
        }
    }

}
