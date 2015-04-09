//
//  PostDetailHeaderView.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/06.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostDetailHeaderView: UIView {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    
    @IBOutlet weak var postImageViewHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        avatarImageView.layer.cornerRadius = 18.0
        avatarImageView.layer.masksToBounds = true
    }
    
    var viewWidth: CGFloat!
    
    var post: Post! {
        didSet {
            if let imageSize = post.imageSize {
                postImageViewHeightConstraint.constant = viewWidth * imageSize.height / imageSize.width
            } else {
                postImageViewHeightConstraint.constant = 0
            }
            
//            TestData.getRandomAvatarPath { (path) -> Void in
//                if let path = path {
//                    self.avatarImageView.sd_setImageWithURL(NSURL(string: path))
//                }
//            }
            
            userName.text = post.owner?.fullName()
            timeLabel.text = Util.displayDate(post.createDate)
            
            if let imagePath = post.imagePath {
                postImageView.setImageWithURL(NSURL(string: imagePath), completed: { (image, error, cacheType, url) -> Void in
                    }, usingActivityIndicatorStyle: .Gray)
            }
            contentLabel.text = post.content
            
            commentsCount.text = "\(post.comments.count)条评论"
        }
    }

    var viewHeight: CGFloat! {
        get {
            contentLabel.preferredMaxLayoutWidth = viewWidth
            
            let size = self.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) as CGSize
            
            return size.height
        }
    }

}
