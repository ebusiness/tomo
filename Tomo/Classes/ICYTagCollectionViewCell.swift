//
//  ICYTagCollectionViewCell.swift
//  Tomo
//
//  Created by eagle on 15/10/5.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ICYTagCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ICYTagCollectionViewCellIdentifier"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let affineTransform = CGAffineTransformScale(CGAffineTransformIdentity, -1, 1)
        contentView.layer.setAffineTransform(affineTransform)
    }

}
