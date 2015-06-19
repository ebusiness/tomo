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
    
    var text_state1 = ""
    var text_state2 = ""
    var text_state3 = ""
    var text_state4 = ""
    
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
        
        self.setSwipe(.State1, completionBlock: { (cell, state, model) -> Void in
            
        })
        self.setSwipe(.State2, completionBlock: { (cell, state, model) -> Void in
            
        })
        self.setSwipe(.State3, completionBlock: { (cell, state, model) -> Void in
            
        })
        self.setSwipe(.State4, completionBlock: { (cell, state, model) -> Void in
            
        })
    }
    
    func setSwipe(state: MCSwipeTableViewCellState, completionBlock: MCSwipeCompletionBlock!) {
        var backgroundColor = UIColor.grayColor()
        
        let image = Util.coloredImage(UIImage(named: "ic_add_black_48dp")!, color: UIColor.whiteColor())
        let imageView = UIImageView(image: image)
        imageView.contentMode =  .Center
        
        var sss =  ( String )(state.rawValue ?? 0)
        
        if state == .State1 || state == .State2 {
            
            backgroundColor = UIColor.greenColor()
        }else if  state == .State3 || state == .State4 {
            
            backgroundColor = UIColor.redColor()
        }
        self.setSwipeGestureWithView(imageView, color: backgroundColor, mode: .Switch, state: state, completionBlock: completionBlock)
        
    }

//    func setChecked(checked: Bool) {
//        let imageName = checked ? "friend_check_on" : "friend_check_off"
//        
//        checkImageView.image = UIImage(named: imageName)
//    }

}
