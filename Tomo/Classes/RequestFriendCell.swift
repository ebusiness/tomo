//
//  RequestFriendCell.swift
//  Tomo
//
//  Created by starboychina on 2015/07/28.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//



import UIKit

class RequestFriendCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var user: User? {
        didSet {
            
            if let photo_ref = user?.photo_ref {
                avatarImageView.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
            }
            
            userNameLabel.text = user?.nickName
            
            //        timeLabel.text = ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = avatarImageView.layer.bounds.width / 2
        avatarImageView.layer.masksToBounds = true
    }
    
}

