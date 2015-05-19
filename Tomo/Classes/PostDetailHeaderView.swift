//
//  PostDetailHeaderView.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/06.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

@objc protocol PostDetailHeaderViewDelegate {
    func commentBtnTapped()
    func avatarImageTapped()
    func imageViewTapped(imageView: UIImageView)
    func shareBtnTapped()
}

class PostDetailHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    
    @IBOutlet weak var postImageViewHeightConstraint: NSLayoutConstraint!

    weak var delegate: PostDetailHeaderViewDelegate?
    
    var layoutSize: CGSize!
    
    override func awakeFromNib() {
        avatarImageView.layer.cornerRadius = 18.0
        avatarImageView.layer.masksToBounds = true
    }
    
    var viewWidth: CGFloat!
    
    var post: Post! {
        didSet {
            if let photo_ref = post.owner?.photo_ref {
                avatarImageView.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
            }
            
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
            if let imageSize = post.imageSize {
                postImageViewHeightConstraint.constant = viewWidth * imageSize.height / imageSize.width
            } else {
                postImageViewHeightConstraint.constant = 0
            }
            
            contentLabel.preferredMaxLayoutWidth = viewWidth - 2*8
            
            let size = self.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) as CGSize
            
            return size.height
        }
    }

    // MARK: - Action
    
    @IBAction func commentBtnTapped(sender: AnyObject) {
        delegate?.commentBtnTapped()
    }
    
    @IBAction func avatarImageTapped(sender: UITapGestureRecognizer) {
        delegate?.avatarImageTapped()
    }
    
    @IBAction func postImageViewTapped(sender: UITapGestureRecognizer) {
        delegate?.imageViewTapped(postImageView)
    }
    
    @IBAction func shareBtnTapped(sender: AnyObject) {
        delegate?.shareBtnTapped()
    }
}