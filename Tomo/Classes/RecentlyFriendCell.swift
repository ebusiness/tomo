//
//  RecentlyFriendCell.swift
//  spot
//
//  Created by 張志華 on 2015/02/20.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class RecentlyFriendCell: MCSwipeTableViewCell {

    @IBOutlet weak var membersCountLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var badgeBackView: UIView!
    
    var handler: SuccessHandler?
    
    var badgeView: JSBadgeView!
    
    var friend: User! {
        didSet {
            if friend.hasIdOnly {
                ApiController.getUserInfo(friend.id!, done: { (error) -> Void in
                    self.updateUI()
                })
            } else {
                updateUI()
            }
        }
    }
    
    var unreadCount: Int?
    
    func updateUI() {
        membersCountLabel.hidden = true
        
        if let photo_ref = friend.photo_ref {
            friendImageView.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
        }
        
        friendNameLabel.text = friend.nickName
        
        if let count = unreadCount where unreadCount > 0 {
            badgeView.hidden = false
            badgeView.badgeText = String(count)
        }
        
        if let message = DBController.lastMessage(friend) {
            if message.isMediaMessage() {
                messageLabel.text = MediaMessage.messagePrefix(message.content!)
            } else {
                messageLabel.text = message.content
            }
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            if let date = message.createDate {
                timeLabel.text = dateFormatter.stringFromDate(date)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        badgeView = JSBadgeView(parentView: badgeBackView, alignment: .Center)
        badgeView.badgeBackgroundColor = Util.UIColorFromRGB(0x0EAA00, alpha: 1)
        
        setupDefault()
    }
    
    override func prepareForReuse() {
        setupDefault()
    }

    func setupDefault() {
        membersCountLabel.hidden = true
        
//        friendImageView.image = Util.avatarImageWithData(nil, diameter: kAvatarImageSize)
        friendNameLabel.text = ""
        messageLabel.text = ""
        timeLabel.text = ""
        badgeView.hidden = true
    }

    func clearBadge() {
        badgeView.hidden = true
    }
}
