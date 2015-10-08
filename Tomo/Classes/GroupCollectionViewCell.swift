//
//  RecommendGroupCell.swift
//  Tomo
//
//  Created by ebuser on 2015/09/16.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class GroupCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var siteNameLabel: UILabel!
    @IBOutlet weak var siteIntroductionLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var protectionView: UIImageView!
    
    var group: GroupEntity!
    
    func setupDisplay() {
        
        self.imageView.setImageWithURL(NSURL(string: group.cover), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.siteNameLabel.text = group.name
        self.siteIntroductionLabel.text = group.introduction
        self.stationLabel.text = group.station
    }
}
