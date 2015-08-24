//
//  SearchFriendCell.swift
//  Tomo
//
//  Created by starboychina on 2015/08/24.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class SearchFriendCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    var user: UserEntity! {
        didSet {
            if let photo = user.photo {
                avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
            }
            
            userNameLabel.text = user.nickName
            bioLabel.text = (user.bio ?? "" ).length > 0 ? user.bio : "这家伙很懒,什么都没写."
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = avatarImageView.layer.bounds.width / 2
        avatarImageView.layer.masksToBounds = true
    }
    
}
