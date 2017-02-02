//
//  NotificationView.swift
//  Tomo
//
//  Created by starboychina on 2015/09/07.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NotificationView: UIView {
    
    @IBOutlet weak var backgroundView: UIView!

    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var messageLabelView: UILabel!

    @IBOutlet weak var closeButton: UIButton!

    weak var delegate: TabBarController!

    var notification: NotificationEntity! {
        didSet {
            if let photo = self.notification.from.photo {
                self.avatarImageView.sd_setImage(with: URL(string: photo), placeholderImage: defaultAvatarImage)
            }

            self.messageLabelView.text = self.notification.message
        }
    }

    @IBAction func closeTapped() {
        gcd.async(.default) {
            self.superview!.constraints.forEach({ (constraint) in
                if !(constraint.firstAttribute == .top && constraint.firstItem is NotificationView) { return }
                gcd.sync(.main) {
                    constraint.constant = -64
                    UIView.animate(withDuration: 0.2, animations: { () -> Void in
                        self.superview?.layoutIfNeeded()
                    })
                }
                
            })
        }
    }
    
    @IBAction func bodyTapped(_ sender: UITapGestureRecognizer) {
        
        if let event = ListenerEvent(rawValue: self.notification.type) {
            
            switch event {
            case .Announcement:
                return
            case .GroupMessage: // GroupMessage
                URLSchemesController.sharedInstance.handleOpenURL(URL(string: "tomo://\(self.notification.type)/\(self.notification.targetId)")!)
                
            case .Message: // Message
                fallthrough
                
            case .FriendAccepted, .FriendRefused, .FriendBreak, .FriendInvited: // User
                
                self.avatarTapped(sender)
                
            case .PostNew, .PostLiked, .PostCommented, .PostBookmarked: // Post
                URLSchemesController.sharedInstance.handleOpenURL(URL(string: "tomo://\(self.notification.type)/\(self.notification.targetId)")!)
                
            default:
                break
            }
        }
    }
    
    @IBAction func avatarTapped(_ sender: UITapGestureRecognizer) {
        URLSchemesController.sharedInstance.handleOpenURL(URL(string: "tomo://\(self.notification.type)/\(self.notification.targetId)")!)
    
    }
    
}
