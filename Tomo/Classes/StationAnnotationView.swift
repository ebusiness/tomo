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
    
    required init?(coder aDecoder: NSCoder) {
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
        nameLabel.font = UIFont.systemFontOfSize(10)
        nameLabel.numberOfLines = 0
        nameLabel.clipsToBounds = true
        nameLabel.backgroundColor = Palette.Red.getPrimaryColor()
        nameLabel.layer.borderWidth = 2
        nameLabel.layer.borderColor = UIColor.whiteColor().CGColor
        nameLabel.layer.cornerRadius = 20
        
        addSubview(nameLabel)
        
        numberBadge.frame = CGRect(x: 25, y: 0, width: 15, height: 15)
        numberBadge.layer.cornerRadius = numberBadge.frame.width / 2
    }
    
    override func setupDisplay() {
        
        let annotation = self.annotation as! GroupAnnotation
        
        var count = annotation.group.posts!.count
        
        if let containedAnnotations = annotation.containedAnnotations {
            
            count = containedAnnotations.reduce(count, combine: { (initCount, containedAnnotation) -> Int in
                let containedAnnotation = containedAnnotation as! GroupAnnotation
                return initCount + containedAnnotation.group.posts!.count
            })
        }
        
        var color = Palette.Red.getLightPrimaryColor()
        
        if count > 0 {
            numberBadge.text = "\(count)"
            addSubview(numberBadge)
        } else {
            numberBadge.removeFromSuperview()
        }
        
        switch count {
        case 1..<10:
            color = Palette.Pink.getAccentColor()
        case 10..<30:
            color = Palette.Pink.getPrimaryColor()
        case 30..<Int.max:
            color = Palette.Pink.getDarkPrimaryColor()
        default:
            color = Palette.Teal.getAccentColor()
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.nameLabel.backgroundColor = color
        })

        nameLabel.text = annotation.group.name
        
//        if let station = annotation.group.station, color = station.color {
//            nameLabel.backgroundColor = Util.colorWithHexString(color)
//        }
    }
}
