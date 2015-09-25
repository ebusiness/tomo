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
    @IBOutlet weak var lineLabel: UILabel!
    
    var station: StationEntity!
    
    func setupDisplay() {
        
        let color = Palette.Blue//Palette(index: Int(arc4random_uniform(UInt32(16))))
        
        self.nameLabel.text = self.station.name
        self.lineLabel.text = self.station.line
        
        self.nameLabel.textColor = color.getTextIconColor()
        self.lineLabel.textColor = color.getTextIconColor()
        self.backgroundColor = color.getPrimaryColor()
    }
}
