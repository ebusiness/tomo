//
//  FriendInvitedCell.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

@objc protocol FriendInvitedCellDelegate {
    
    func friendInvitedCellAllowed(cell: FriendInvitedCell)
}

class FriendInvitedCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    weak var delegate: FriendInvitedCellDelegate?
    
    var friendInvitedNotification: Notification! {
        didSet {
            let user = friendInvitedNotification.from!
            nameLabel.text = user.fullName()
            
            if let photo_ref = user.photo_ref {
                avatarImageView.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func allow(sender: AnyObject) {
        delegate?.friendInvitedCellAllowed(self)
    }
    
    @IBAction func disallow(sender: AnyObject) {
        Util.showTodo()
    }
}
