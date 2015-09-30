//
//  NotificationView.swift
//  Tomo
//
//  Created by starboychina on 2015/09/07.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NotificationView: UIView {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabelView: UILabel!
    @IBOutlet weak var messageLabelView: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    var notification: NotificationEntity! {
        didSet {
            if let photo = self.notification.from.photo {
                self.avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
            }
            
            self.nickNameLabelView.text = self.notification.from.nickName
            self.messageLabelView.text = self.notification.message
            gcd.async(.Default, delay: 5) {
                self.closeTapped()
            }

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Util.changeImageColorForButton(self.closeButton, color: UIColor.whiteColor())
        gcd.async(.Default) {
            self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
            self.avatarImageView.layer.masksToBounds = true
            self.backgroundView.backgroundColor = Util.UIColorFromRGB(NavigationBarColorHex, alpha: 1)
        }
    }

    @IBAction func closeTapped() {
        gcd.async(.Default) {
            let topConstraint: AnyObject? = self.superview!.constraints().find { $0.firstAttribute == .Top && $0.firstItem is NotificationView }
            if let topConstraint = topConstraint as? NSLayoutConstraint {
                gcd.sync(.Main) {
                    topConstraint.constant = -64
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.superview?.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
    @IBAction func bodyTapped(sender: UITapGestureRecognizer) {
        
        if let event = ListenerEvent(rawValue: self.notification.type) {
            
            switch event {
            case .Announcement:
                
                println("系统通知")
                return
                
            case .GroupMessage: // GroupMessage
                
                let id = "/\(self.notification.targetId)"
                let host = self.notification.type
                URLSchemesController.sharedInstance.handleOpenURL(NSURL(scheme: "tomo", host: host, path: id)!)
                
            case .Message: // Message
                fallthrough
                
            case .FriendAccepted, .FriendRefused, .FriendBreak, .FriendInvited: // User
                
                self.avatarTapped(sender)
                
            case .PostNew, .PostLiked, .PostCommented, .PostBookmarked: // Post
                
                let id = "/\(self.notification.targetId)"
                let host = self.notification.type
                URLSchemesController.sharedInstance.handleOpenURL(NSURL(scheme: "tomo", host: host, path: id)!)
                
            default:
                break
            }
            
        
        }
    }
    
    @IBAction func avatarTapped(sender: UITapGestureRecognizer) {
        
        let id = "/\(self.notification.from.id)"
        let host = self.notification.type
        URLSchemesController.sharedInstance.handleOpenURL(NSURL(scheme: "tomo", host: host, path: id)!)
    
    }
    
}