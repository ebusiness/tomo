//
//  ICYCollectionViewSingleImageCell.swift
//  Tomo
//
//  Created by eagle on 15/10/6.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ICYCollectionViewSingleImageCell: UICollectionViewCell {
    static let identifier = "ICYCollectionViewSingleImageCellIdentifier"
    
    var imageURL: String? {
        didSet {
            let placeholderImage = UIImage(named: "placeholder")
            if let url = imageURL {
                imageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: placeholderImage)
            } else {
                imageView.image = placeholderImage
            }
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
