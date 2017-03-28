//
//  NotificationView.swift
//  Tomo
//
//  Created by starboychina on 2015/09/07.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit

class NotificationView: UIView {

    @IBOutlet weak fileprivate var avatarImageView: UIImageView!

    @IBOutlet weak fileprivate var messageLabelView: UILabel!

    @IBOutlet weak fileprivate var closeButton: UIButton!

    var notification: NotificationEntity! {
        didSet {
            if let photo = self.notification.from.photo {
                self.avatarImageView.sd_setImage(with: URL(string: photo), placeholderImage: defaultAvatarImage)
            }

            self.messageLabelView.text = self.notification.message
        }
    }

    @IBAction func closeTapped() {
        DispatchQueue.default.async {
            self.superview!.constraints.forEach({ (constraint) in
                if !(constraint.firstAttribute == .top && constraint.firstItem is NotificationView) { return }
                DispatchQueue.main.sync {
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
                let url = URL(string: "tomo://\(self.notification.type)/\(self.notification.targetId)")!
                URLSchemesController.shared.handleOpen(url: url)

            case .Message: // Message
                fallthrough

            case .FriendAccepted, .FriendRefused, .FriendBreak, .FriendInvited: // User

                self.avatarTapped(sender)

            case .PostNew, .PostLiked, .PostCommented, .PostBookmarked: // Post
                let url = URL(string: "tomo://\(self.notification.type)/\(self.notification.targetId)")!
                URLSchemesController.shared.handleOpen(url: url)

            default:
                break
            }
        }
    }

    @IBAction func avatarTapped(_ sender: UITapGestureRecognizer) {
        let url = URL(string: "tomo://\(self.notification.type)/\(self.notification.targetId)")!
        URLSchemesController.shared.handleOpen(url: url)

    }

}
