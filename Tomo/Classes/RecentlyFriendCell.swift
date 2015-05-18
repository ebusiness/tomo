//
//  RecentlyFriendCell.swift
//  spot
//
//  Created by 張志華 on 2015/02/20.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class RecentlyFriendCell: UITableViewCell {

    @IBOutlet weak var membersCountLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var badgeBackView: UIView!
    
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
        
        friendNameLabel.text = friend.fullName()
        
        if let count = unreadCount where unreadCount > 0 {
            badgeView.hidden = false
            badgeView.badgeText = String(count)
        }
        
        if let message = DBController.lastMessage(friend) {
            if message.isMediaMessage() {
                messageLabel.text = imageMessagePrefix
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
    
//    var friend: XMPPMessageArchiving_Contact_CoreDataObject! {
//        didSet {
//            
//            if !friend.isGroupChat() {
//                membersCountLabel.hidden = true
//            } else {
//                friendNameLabel.text = "グループ名"
////                membersCountLabel.hidden = false
//                membersCountLabel.text = "\(XMPPManager.countOfRoom(friend.bareJidStr))"
//            }
//            
//            if friend.mostRecentMessageBody.messageType() != .Text {
//                self.messageLabel.text = friend.mostRecentMessageBody.messageType().rawValue
//            } else {
//                self.messageLabel.text = friend.mostRecentMessageBody
//            }
//            
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateStyle = .ShortStyle
//            self.timeLabel.text = dateFormatter.stringFromDate(friend.mostRecentMessageTimestamp)
//            
//            if let friend = Friend.MR_findFirstByAttribute("jidStr", withValue: friend.bareJidStr) as? Friend {
//                if friend.unreadMessagesValue > 0 {
//                    badgeView.hidden = false
//                    badgeView.badgeText = String(friend.unreadMessagesValue)
//                } else {
//                    badgeView.hidden = true
//                }
//            }
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        badgeView = JSBadgeView(parentView: badgeBackView, alignment: .Center)
        badgeView.badgeBackgroundColor = UIColor(hexString: "#0EAA00")
        
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
