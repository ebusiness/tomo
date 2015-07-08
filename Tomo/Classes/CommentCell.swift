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
    
    var comment: Comments! {
        didSet {
            if let photo_ref = comment.owner?.photo_ref {
                avatarImageView.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
            }
            
            userNameLabel.text = comment.owner?.nickName
            timeLabel.text = Util.displayDate(comment.createDate)
            contentLabel.text = comment.content
        }
    }
    
    func height(comment: Comments, width: CGFloat) -> CGFloat {
        contentLabel.preferredMaxLayoutWidth = width - 8 - 36 - 8
        
        userNameLabel.text = comment.owner?.nickName
        timeLabel.text = Util.displayDate(comment.createDate)
        contentLabel.text = comment.content
        
        let size = contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) as CGSize
        return size.height
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = 18.0
        avatarImageView.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
