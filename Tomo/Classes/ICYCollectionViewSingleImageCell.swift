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
    
    static let minCenterScale = CGFloat(1.5)
    static let maxAspectFitScale = CGFloat(3.5)
    static let minAspectFitScale = CGFloat(1 / 3.5)
    
    var imageURL: String? {
        didSet {
            let placeholderImage = UIImage(named: "placeholder")
            if let url = imageURL {
                imageView.contentMode = .ScaleAspectFill
                imageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: placeholderImage, completed: { (image, _, _, _) -> Void in
                    if image == nil {
                        self.imageView.contentMode = .ScaleAspectFill
                        return
                    }
                    let size = image.size
                    let ratio = size.width / size.height
                    if size.height < (self.imageView.bounds.height / ICYCollectionViewSingleImageCell.minCenterScale)
                        && size.width < (self.imageView.bounds.width / ICYCollectionViewSingleImageCell.minCenterScale) {
                        self.imageView.contentMode = .Center
                    } else if ratio > ICYCollectionViewSingleImageCell.maxAspectFitScale
                    || ratio < ICYCollectionViewSingleImageCell.minAspectFitScale {
                        self.imageView.contentMode = .ScaleAspectFit
                    }else {
                        self.imageView.contentMode = .ScaleAspectFill
                    }
                })
            } else {
                imageView.contentMode = .ScaleAspectFill
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
