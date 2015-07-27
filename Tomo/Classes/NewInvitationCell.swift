//
//  NewInvitationCell.swift
//  Tomo
//
//  Created by ebuser on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

@objc protocol FriendInvitationCellDelegate {
    
    func friendInvitationAccept(cell: NewInvitationCell)
    func friendInvitationDeclined(cell: NewInvitationCell)
}

class NewInvitationCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var declinedButton: UIButton!
    
    var friendInvitedNotification: Notification?
    
    weak var delegate: FriendInvitationCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        avatarImageView.layer.cornerRadius = avatarImageView.layer.bounds.width / 2
        avatarImageView.layer.masksToBounds = true
        Util.changeImageColorForButton(declinedButton,color: UIColor.redColor())
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupDisplay() {
        
        let user = friendInvitedNotification!.from
        
        if let photo_ref = user?.photo_ref {
            avatarImageView.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
        }
        
        userNameLabel.text = user?.nickName

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        if let date = friendInvitedNotification!.createDate {
            timeLabel.text = dateFormatter.stringFromDate(date)
        } else {
            timeLabel.hidden = true
        }
        
    }
    
    @IBAction func allow(sender: AnyObject) {
        
        self.delegate?.friendInvitationAccept(self)

    }
    
    @IBAction func declined(sender: UIButton) {
        
        self.delegate?.friendInvitationDeclined(self)

    }
    
    
}
