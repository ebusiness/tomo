//
//  StationCollectionViewCell.swift
//  Tomo
//
//  Created by ebuser on 2015/09/24.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class StationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var prefLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var group: GroupEntity!
    
    func setupDisplay() {
        self.nameLabel.text = self.group.name
        self.prefLabel.text = self.group.pref
        backgroundImageView.sd_setImageWithURL(NSURL(string: group.cover), placeholderImage: TomoConst.Image.DefaultGroup)
    }
}
