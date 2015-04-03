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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 3.0
    }
    
    var post: Post! {
        didSet {
            
        }
    }
    
    var imageSize: CGSize!
    
    func configCell() {
        if heightConstraint != nil {
            heightConstraint.active = false
        }
        
        imageView.setImageWithURL(NSURL(string: imagePath()), completed: { (image, error, cacheType, url) -> Void in
            if image == nil {
//                imageView.image = ITEM_NOIMAGE
            }
            }, usingActivityIndicatorStyle: .Gray)
    }
    
    func imagePath() -> String {
        return kBasePath + "/\(Int(imageSize.width))" + "/\(Int(imageSize.height))"
    }
    
    func sizeOfCell(cellWidth: CGFloat) -> CGSize {
        heightConstraint.constant = cellWidth * imageSize.height / imageSize.width
        
        let size = self.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) as CGSize
        return size
    }
}
