//
//  InvitationCell.swift
//  Tomo
//
//  Created by ebuser on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class InvitationCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var friendInvitedNotification: NotificationEntity!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupDisplay() {
        
        let user = friendInvitedNotification.from
        
        if let photo = user.photo {
            avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
        }
        
        userNameLabel.text = user.nickName
        
    }
    
    @IBAction func allow(sender: AnyObject) {
        
        Router.Invitation.ModifyById(id: self.friendInvitedNotification.id, accepted: true).response {
            if $0.result.isFailure { return }
            me.addFriend(self.friendInvitedNotification.from)
        }

    }
    
    @IBAction func declined(sender: UIButton) {
        
//        let vc = window?.rootViewController?.childViewControllers.first?.tabBarController?.selectedViewController?.childViewControllers.last
        guard let vc = window?.rootViewController else { return }
        
        Util.alert(vc, title: "拒绝好友邀请", message: "拒绝 " + self.friendInvitedNotification.from.nickName + " 的好友邀请么") { _ in
            Router.Invitation.ModifyById(id: self.friendInvitedNotification.id, accepted: false).response {
                if $0.result.isFailure { return }
                me.removeFriend(self.friendInvitedNotification.from)
            }
        }

    }
    
    
}
