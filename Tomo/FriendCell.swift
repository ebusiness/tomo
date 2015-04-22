//
//  FriendCell.swift
//  spot
//
//  Created by 張志華 on 2015/03/10.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {
    
//    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var invitedLabel: UILabel!
    
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
    
    func updateUI() {
        if let photo_ref = friend.photo_ref {
            friendImageView.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
        }
        
        nameLabel.text = friend.fullName()
        
        invitedLabel.hidden = !DBController.isInvitedUser(friend)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        friendImageView.layer.cornerRadius = friendImageView.bounds.width / 2
    }

//    func setChecked(checked: Bool) {
//        let imageName = checked ? "friend_check_on" : "friend_check_off"
//        
//        checkImageView.image = UIImage(named: imageName)
//    }

}
