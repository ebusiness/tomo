//
//  FriendCell.swift
//  spot
//
//  Created by 張志華 on 2015/03/10.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class FriendCell: MCSwipeTableViewCell {
    
//    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var invitedLabel: UILabel!
    @IBOutlet weak var tagListView: AMTagListView!
    
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
        
        nameLabel.text = friend.nickName
        
        invitedLabel.hidden = !DBController.isInvitedUser(friend)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        friendImageView.layer.cornerRadius = friendImageView.bounds.width / 2
        
        
        if let tagListView = self.tagListView {
            tagListView.tagListDelegate = self
            
            self.defaultColor = Util.UIColorFromRGB(0xEAEAEA, alpha: 1)
        }
    }

//    func setChecked(checked: Bool) {
//        let imageName = checked ? "friend_check_on" : "friend_check_off"
//        
//        checkImageView.image = UIImage(named: imageName)
//    }

}

extension FriendCell {
    //タグを追加する
    func addTag(tag: Tag){
        if let name = tag.name where !name.isEmpty {
            tagUIController.setTagView(.small)
            self.tagListView.addTag(name)
        }
    }
    func addTags(array: [AnyObject]!){
        tagListView.hidden = array.count == 0 && self.tagListView.tags.count == 0
        if !tagListView.hidden {
            tagUIController.setTagView(.small)
        }
        self.tagListView.addTags(array)
    }
}


extension FriendCell : AMTagListDelegate {
    //タグ表示数
    func tagList(tagListView: AMTagListView!, shouldAddTagWithText text: String!, resultingContentSize size: CGSize) -> Bool {
        return tagListView.tags.count < 4
    }
}
