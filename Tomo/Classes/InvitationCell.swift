//
//  InvitationCell.swift
//  Tomo
//
//  Created by ebuser on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

@objc protocol FriendInvitationCellDelegate {
    
    func friendInvitationAccept(cell: InvitationCell)
    func friendInvitationDeclined(cell: InvitationCell)
}

class InvitationCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var friendInvitedNotification: NotificationEntity!
    
    weak var delegate: FriendInvitationCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.borderColor = avatarBorderColor
        
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
        
        self.delegate?.friendInvitationAccept(self)

    }
    
    @IBAction func declined(sender: UIButton) {
        
        self.delegate?.friendInvitationDeclined(self)

    }
    
    
}
