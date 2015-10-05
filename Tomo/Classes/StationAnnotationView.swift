//
//  StationAnnotationView.swift
//  Tomo
//
//  Created by ebuser on 2015/09/30.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class StationAnnotationView: AggregatableAnnotationView {
    
    var nameLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation!, reuseIdentifier: String!) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.font = UIFont.systemFontOfSize(12)
        nameLabel.numberOfLines = 0
        nameLabel.clipsToBounds = true
        nameLabel.layer.borderWidth = 1
        nameLabel.layer.borderColor = Palette.Green.getPrimaryColor().CGColor
        nameLabel.layer.cornerRadius = 5
        
        addSubview(nameLabel)
        
        numberBadge.frame = CGRect(x: 28, y: -8, width: 20, height: 20)
        numberBadge.layer.cornerRadius = numberBadge.frame.width / 2
    }
    
    override func setupDisplay() {
        super.setupDisplay()
        
        let annotation = self.annotation as! StationAnnotation
        nameLabel.text = annotation.station.name
        nameLabel.backgroundColor = Util.colorWithHexString(annotation.station.color!)

    }
}
