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
    @IBOutlet weak var bioLabel: UILabel!
    
    var user: UserEntity? {
        didSet {
            
            if let photo = user?.photo {
                avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
            }
            
            userNameLabel.text = user?.nickName
            bioLabel.text = user?.bio
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatarImageView.layer.cornerRadius = avatarImageView.layer.bounds.width / 2
        self.avatarImageView.layer.masksToBounds = true
    }
    
}

