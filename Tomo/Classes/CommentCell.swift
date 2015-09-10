//
//  CommentCell.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/06.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    var parentVC:UIViewController?
    
    var comment: CommentEntity! {
        didSet {
            if let photo = comment.owner.photo {
                avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
            }
            
            userNameLabel.text = comment.owner.nickName
            timeLabel.text = comment.createDate.relativeTimeToString()
            contentLabel.text = comment.content
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height / 2
        avatarImageView.layer.masksToBounds = true
        
        if avatarImageView.userInteractionEnabled {
            let tap = UITapGestureRecognizer(target: self, action: Selector("avatarImageTapped:"))
            avatarImageView.addGestureRecognizer(tap)
        }
        
    }

}

extension CommentCell {
    
    func height(comment: CommentEntity, width: CGFloat) -> CGFloat {
        contentLabel.preferredMaxLayoutWidth = width - 8 - 36 - 8
        
        userNameLabel.text = comment.owner.nickName
        timeLabel.text = comment.createDate.relativeTimeToString()
        contentLabel.text = comment.content
        
        let size = contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) as CGSize
        return size.height
    }
    
    func avatarImageTapped(sender: UITapGestureRecognizer) {
        
        if let childvcs = self.parentVC?.navigationController?.childViewControllers where childvcs.count > 4 {
            for index in 1..(childvcs.count-1) {
                childvcs[index].removeFromParentViewController()
            }
        }
        
        let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
        vc.user = comment.owner
        self.parentVC?.navigationController?.pushViewController(vc, animated: true)
    }
}
