//
//  NewsfeedCell.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/02.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

let kBasePath = "http://lorempixel.com"

class NewsfeedCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 3.0
        avatarImageView.layer.cornerRadius = 12.0
        avatarImageView.layer.masksToBounds = true
    }
    
    var post: Post! {

        didSet {
            
        }
    }
    
    var imageSize: CGSize!
    
    func configCell() {
        if heightConstraint != nil {
//            heightConstraint.active = false
            imageView.removeConstraint(heightConstraint)
        }
        
        updateTitleWithPost()
        
        if let owner = post.owner {
            userNameLabel.text = owner.fullName()
        } else {
            userNameLabel.text = nil
        }
        
        if avatarImageView.image == nil {
            TestData.getRandomAvatarPath { (path) -> Void in
                if let path = path {
                    self.avatarImageView.sd_setImageWithURL(NSURL(string: path))
                }
            }
        }

        let now = NSDate()
        if let date = post.createDate {
            if !date.isToday() {
                dateLabel.text = date.toString()
            } else if date.hoursBeforeDate(now) > 0 {
                dateLabel.text = "\(date.hoursBeforeDate(now))時"
            } else if date.minutesBeforeDate(now) > 0 {
                dateLabel.text = "\(date.minutesBeforeDate(now))分"
            } else {
                dateLabel.text = "\(date.seconds())秒"
            }
        }
        
        if post.imagesmobile.count > 0 {
            let image = post.imagesmobile.anyObject() as Images
            println(image.name)
        }
        
        imageView.setImageWithURL(NSURL(string: imagePath()), completed: { (image, error, cacheType, url) -> Void in
            if cacheType == .None {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.imageView.alpha = 0.2
                    self.imageView.alpha = 1
                })
            }
        }, usingActivityIndicatorStyle: .Gray)
    }
    
    func imagePath() -> String {
        return kBasePath + "/\(Int(imageSize.width))" + "/\(Int(imageSize.height))"
    }
    
    func sizeOfCell(cellWidth: CGFloat) -> CGSize {
        heightConstraint.constant = cellWidth * imageSize.height / imageSize.width
        
        updateTitleWithPost()
        
        let labelWidth = cellWidth - 2*8
        detailLabel.preferredMaxLayoutWidth = labelWidth
        titleLabel.preferredMaxLayoutWidth = labelWidth
        
        let size = self.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) as CGSize
        return size
    }
    
    //計算関係ある
    func updateTitleWithPost() {
        //title
        titleLabel.text = nil
        detailLabel.text = post.content
        
        if titleLabel.text == nil {
            titleBottomSpace.constant = 0
        }
    }
}
